import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
    const env = { ...process.env };
    if (!env.ZELLIJ_SESSION_NAME || !/^\d+$/.test(env.ZELLIJ_PANE_ID ?? "")) return;
    const script = join(homedir(), ".config/zellij/integrations/pane-status.sh");
    let outcome = "done";
    // The smart-tabs plugin renders unknown status strings verbatim (its `sub`
    // status map only matches the plain words used by other agents), so pi
    // sends pre-rendered "<icon> <model>" strings.
    const ICONS: Record<string, string> = {
        running: "⏳",
        pending: "⏳",
        done: "✅",
        error: "❌",
    };
    let currentModel = "";
    let lastState = "idle";
    const remember = (label: string | undefined) => {
        const trimmed = label?.trim();
        if (!trimmed || trimmed === currentModel) return;
        currentModel = trimmed;
        // Refresh the tab if the model arrived after the status was sent.
        if (lastState === "running" || lastState === "pending") {
            void send(render(lastState));
        }
    };
    // ctx.model is often still undefined around the first agent_start of a
    // fresh session, so fall back to the branch's last model_change entry.
    const setModel = (ctx: {
        model?: { name?: string; id: string } | undefined;
        sessionManager?: { getBranch?: () => { type: string; modelId?: string }[] };
    }) => {
        remember(ctx.model?.name || ctx.model?.id);
        if (currentModel) return;
        const entries = ctx.sessionManager?.getBranch?.() ?? [];
        for (let i = entries.length - 1; i >= 0; i--) {
            if (entries[i].type === "model_change") {
                remember(entries[i].modelId);
                break;
            }
        }
    };
    const render = (status: string) =>
        status === "idle" || !currentModel ? status : `${ICONS[status] ?? ""} ${currentModel}`.trim();
    let queue = Promise.resolve();
    const send = (status: string) => {
        queue = queue.then(() => new Promise<void>((resolve) => {
            execFile("bash", [script, status], { env, timeout: 2500 }, () => resolve());
        }));
        return queue;
    };
    const sendState = (status: string) => {
        lastState = status;
        return send(render(status));
    };
    pi.on("session_start", (_event, ctx) => {
        setModel(ctx);
        return sendState("idle");
    });
    pi.on("model_select", (event) => {
        remember(event.model.name || event.model.id);
        return sendState("pending");
    });
    pi.on("agent_start", (_event, ctx) => {
        setModel(ctx);
        outcome = "done";
        return sendState("running");
    });
    pi.on("turn_start", (_event, ctx) => {
        setModel(ctx);
        return sendState("running");
    });
    // The assistant message names the concrete model actually serving the
    // request; this is the earliest reliable source on a fresh session.
    pi.on("message_start", (event) => {
        if (event.message.role === "assistant") remember(event.message.model);
    });
    pi.on("turn_end", (event, ctx) => {
        setModel(ctx);
        if (event.message.role === "assistant") {
            remember(event.message.model);
            outcome = event.message.stopReason === "error" ? "error"
                : event.message.stopReason === "aborted" ? "idle" : "done";
        }
        return sendState("pending");
    });
    // agent_end may be followed by automatic retries or queued prompts.
    pi.on("agent_settled", (_event, ctx) => {
        setModel(ctx);
        if (ctx.isIdle()) return sendState(outcome);
    });
    pi.on("session_shutdown", () => send("idle"));
}
