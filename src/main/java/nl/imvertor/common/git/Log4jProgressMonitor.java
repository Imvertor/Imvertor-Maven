package nl.imvertor.common.git;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.eclipse.jgit.lib.ProgressMonitor;
import static java.lang.String.format;

/**
 * JGit ProgressMonitor that reports to Log4j
 */
public class Log4jProgressMonitor implements ProgressMonitor {

  private static final Logger logger = LogManager.getLogger(Log4jProgressMonitor.class);
  private static final long LOG_INTERVAL_MS = 1000;

  private String task;
  private int total;
  private int done;
  private long taskStart;
  private long lastLog;

  @Override
  public void start(int totalTasks) {
    try {
      logger.debug(format("JGit: Starting %s task(s)", totalTasks));
    } catch (Exception e) {
      logger.error("Error logging JGit tasks", e);
    }
  }

  @Override
  public void beginTask(String title, int totalWork) {
    try {
      task = title;
      total = totalWork;
      done = 0;
      taskStart = lastLog = System.currentTimeMillis();
      logger.info(format("JGit: %s started%s", title, total == UNKNOWN ? "" : " (" + total + ")"));
    } catch (Exception e) {
      logger.error("Error logging JGit tasks", e);
    }
  }

  @Override
  public void update(int completed) {
    try {
      done += completed;
      long now = System.currentTimeMillis();
      if (now - lastLog >= LOG_INTERVAL_MS) {
        lastLog = now;
        if (total == UNKNOWN) {
          logger.info(format("JGit: %s: %s", task, done));
        } else {
          logger.info(format("JGit: %s: %s%% (%s/%s)", task, done * 100L / total, done, total));
        }
      }
    } catch (Exception e) {
      logger.error("Error logging JGit tasks", e);
    }
  }

  @Override
  public void endTask() {
    try {
      logger.info(format("JGit: %s done: %s in %s ms", task, done, System.currentTimeMillis() - taskStart));
    } catch (Exception e) {
      logger.error("Error logging JGit tasks", e);
    }
  }

  @Override
  public boolean isCancelled() {
    return false;
  }

  // Required since JGit 6.3; harmless (no @Override) on older versions
  public void showDuration(boolean enabled) {
    // durations are logged in endTask() already
  }
  
}