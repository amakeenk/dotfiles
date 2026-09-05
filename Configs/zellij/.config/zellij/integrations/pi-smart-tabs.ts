import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
    const env = { ...process.env };
    if (!env.ZELLIJ_SESSION_NAME || !/^\d+$/.test(env.ZELLIJ_PANE_ID ?? "")) return;
    const script = join(homedir(), ".config/zellij/integrations/pane-status.sh");
    let outcome = "done";
    let queue = Promise.resolve();
    const send = (status: string) => {
        queue = queue.then(() => new Promise<void>((resolve) => {
            execFile("bash", [script, status], { env, timeout: 2500 }, () => resolve());
        }));
        return queue;
    };
    pi.on("session_start", () => send("idle"));
    pi.on("agent_start", () => {
        outcome = "done";
        return send("running");
    });
    pi.on("turn_start", () => send("running"));
    pi.on("turn_end", (event) => {
        if (event.message.role === "assistant") {
            outcome = event.message.stopReason === "error" ? "error"
                : event.message.stopReason === "aborted" ? "idle" : "done";
        }
        return send("pending");
    });
    // agent_end may be followed by automatic retries or queued prompts.
    pi.on("agent_settled", (_event, ctx) => {
        if (ctx.isIdle()) return send(outcome);
    });
    pi.on("session_shutdown", () => send("idle"));
}
