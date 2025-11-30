/**
 * OpenCode Brag Book Plugin
 * Automatically tracks work sessions and accomplishments
 * Shares data format with brag-lib.sh for consistency
 */
export const BragBookPlugin = async ({ project, client, $, directory }) => {
  const BRAG_DIR = process.env.XDG_DATA_HOME 
    ? `${process.env.XDG_DATA_HOME}/brag-book`
    : `${process.env.HOME}/.local/share/brag-book`;

  let sessionStartTime = null;
  let sessionMessages = [];
  let sessionFiles = new Set();

  // Write brag entry using the shared brag command
  const writeBragEntry = async (summary, source = "opencode-auto", extraData = {}) => {
    if (!summary) return null;
    
    try {
      // Use the brag command directly with simplified approach
      const bragPath = `${process.env.HOME}/dotfiles/stow/scripts/bin/brag`;
      
      // Build the full entry message with extra data if provided
      let fullSummary = summary;
      if (extraData.session_duration) {
        fullSummary += ` (${Math.round(extraData.session_duration / 60)}m)`;
      }
      
      // Call brag command directly
      await $`${bragPath} ${fullSummary}`;
      
      return { success: true, summary: fullSummary };
    } catch (error) {
      console.error("[Brag] Failed to write entry:", error);
      return null;
    }
  };

  // Summarize session based on messages and activity
  const summarizeSession = async () => {
    if (sessionMessages.length === 0) return null;

    const filesModified = Array.from(sessionFiles);
    const duration = sessionStartTime 
      ? Math.round((Date.now() - sessionStartTime) / 60000) 
      : 0;
    
    // Extract main task from user messages
    const userMessages = sessionMessages
      .filter(msg => msg.role === "user")
      .map(msg => msg.content)
      .filter(content => content && content.length > 10);
    
    if (userMessages.length === 0) return null;
    
    // Build concise summary
    let summary = userMessages[0].substring(0, 100);
    if (filesModified.length > 0) {
      summary += ` (${filesModified.length} files)`;
    }
    if (duration > 0) {
      summary += ` - ${duration}m`;
    }
    
    return summary;
  };

  return {
    // Track session start
    "session.created": async () => {
      sessionStartTime = Date.now();
      sessionMessages = [];
      sessionFiles.clear();
    },

    // Track messages
    "message.updated": async ({ event }) => {
      if (event.data?.message) {
        sessionMessages.push({
          role: event.data.message.role || "unknown",
          content: event.data.message.content || ""
        });
      }
    },

    // Track file edits
    "file.edited": async ({ event }) => {
      if (event.data?.filePath) {
        sessionFiles.add(event.data.filePath);
      }
    },

    // Capture on idle or session end
    "session.idle": async () => {
      const summary = await summarizeSession();
      if (summary) {
        const duration = sessionStartTime 
          ? Math.round((Date.now() - sessionStartTime) / 1000)
          : null;
        await writeBragEntry(summary + " (opencode)", "opencode-auto", { 
          session_duration: duration,
          files_count: sessionFiles.size
        });
      }
    },

    "session.deleted": async () => {
      const summary = await summarizeSession();
      if (summary) {
        const duration = sessionStartTime 
          ? Math.round((Date.now() - sessionStartTime) / 1000)
          : null;
        await writeBragEntry(summary + " (opencode)", "opencode-auto", {
          session_duration: duration,
          files_count: sessionFiles.size
        });
      }
    }
  };
};