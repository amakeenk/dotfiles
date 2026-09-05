import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

export const SmartTabs = async ({ client }) => {
    const env = { ...process.env };
    if (!env.ZELLIJ_SESSION_NAME || !/^\d+$/.test(env.ZELLIJ_PANE_ID ?? "")) return {};
    const script = join(homedir(), ".config/zellij/integrations/pane-status.sh");
    const sessions = new Map();
    let queue = Promise.resolve();
    const send = (status) => new Promise((resolve) => {
        execFile("bash", [script, status], { env, timeout: 2500 }, () => resolve());
    });

    return {
        event: ({ event }) => {
            if (!["session.status", "session.error"].includes(event.type)) return;
            // The event bus does not await callbacks. Preserve arrival order.
            queue = queue.then(async () => {
                const id = event.properties.sessionID;
                if (!id) return;
                const { data } = await client.session.get({ path: { id } });
                // Child agents finishing must not mark the parent pane as done.
                if (!data || data.parentID) return;
                const type = event.properties.status?.type;
                let status;
                if (event.type === "session.error") status = "error";
                else if (type === "busy") status = "running";
                else if (type === "retry") status = "pending";
                else if (type === "idle") status = sessions.get(id) === "error" ? "error" : "done";
                else return;
                sessions.set(id, status);
                const states = [...sessions.values()];
                await send(states.includes("running") ? "running"
                    : states.includes("pending") ? "pending" : status);
            }).catch(() => {});
            return queue;
        },
    };
};
