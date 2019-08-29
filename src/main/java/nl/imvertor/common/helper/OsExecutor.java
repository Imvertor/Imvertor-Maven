package nl.imvertor.common.helper;

import java.io.IOException;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteException;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.exec.Executor;

public class OsExecutor {

	public static void main(String[] args) throws Exception {
		OsExecutor tt = new OsExecutor();
		tt.testOsExecutor();
	}
	
    public void testOsExecutor() throws Exception {

        final long osExecutorJobTimeout = 15000;
        final boolean osExecutorInBackground = false;
        OsExecutorResultHandler osExecutorResult = null;

        CommandLine commandLine = new CommandLine("c:\\temp\\test.bat");
        commandLine.addArgument("Lianne-20190828-A-0294-a1.jpg");
        commandLine.addArgument("Lianne-20190828-A-0294-a2.jpg");
        
        try {
	        osExecutorResult = osexec(commandLine, osExecutorJobTimeout, osExecutorInBackground);
	  
	        osExecutorResult.waitFor();
        } catch (Exception e) {
        	if (osExecutorResult != null)
        		System.out.println("Exit value " + osExecutorResult.getExitValue() + ". " + osExecutorResult.getException().getMessage());
        	else 
          		System.out.println(e.getMessage());
        }
    }

    /**
     * Execute a shell command
     *
     * @param commandLine The exe/bat file
     * @param osExecutorJobTimeout (ms) before the watchdog terminates the process
     * @param isexecInBackground execution done in the background or blocking
     * @return a result handler
     * @throws IOException the test failed
     */
   public OsExecutorResultHandler osexec(CommandLine commandLine, final long osExecutorJobTimeout, final boolean osExecutorInBackground)
            throws IOException {

        int exitValue;
        ExecuteWatchdog watchdog = null;
        OsExecutorResultHandler resultHandler;

        // create the executor and consider the exitValue '1' as success
        final Executor executor = new DefaultExecutor();
        executor.setExitValue(0); // this is the default normal return exit code for windows
        
        // create a watchdog if requested
        if (osExecutorJobTimeout > 0) {
            watchdog = new ExecuteWatchdog(osExecutorJobTimeout);
            executor.setWatchdog(watchdog);
        }

        // pass a "ExecuteResultHandler" when doing background osExecutoring
        if (osExecutorInBackground) {
            resultHandler = new OsExecutorResultHandler(watchdog);
            executor.execute(commandLine, resultHandler);
        }
        else {
            exitValue = executor.execute(commandLine);
            resultHandler = new OsExecutorResultHandler(exitValue);
        }

        return resultHandler;
    }

    public class OsExecutorResultHandler extends DefaultExecuteResultHandler {

        public OsExecutorResultHandler(final ExecuteWatchdog watchdog)
        {
        }

        public OsExecutorResultHandler(final int exitValue) {
            super.onProcessComplete(exitValue);
        }
        
        public void onProcessComplete(final int exitValue) {
            super.onProcessComplete(exitValue);
        }

        public void onProcessFailed(final ExecuteException e) {
            super.onProcessFailed(e);
        }
    }
}