package nl.imvertor.common.file;

import java.io.IOException;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteException;
import org.apache.commons.exec.ExecuteResultHandler;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.exec.Executor;
import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;

public class ExecFile extends AnyFile {

	private static final long serialVersionUID = -4926190902168326702L;
	
	protected static final Logger logger = Logger.getLogger(ExecFile.class);
		
	public ExecFile(String pathname) {
		super(pathname);
	}
	
	 /**
     * Execute a shell command
     *
     * @param commandLine The exe/bat file
     * @param osexecJobTimeout (ms) before the watchdog terminates the process
     * @param isexecInBackground execution done in the background or blocking
     * @return a result handler
     * @throws IOException the test failed
     */
	 public int execute(Configurator configurator, String[] arguments, long timeout, boolean async) throws IOException {

		final CommandLine cmdLine = new CommandLine(this.getCanonicalPath());      
		if (arguments != null)
			for (int i = 0; i < arguments.length; ++i) {
				cmdLine.addArgument(arguments[i]);
			}

		Executor executor = new DefaultExecutor();
		ExecuteWatchdog watchdog = new ExecuteWatchdog(timeout);

		executor.setWatchdog(watchdog);                        

		try {
			if (async) {                    
				executor.execute(cmdLine, new ExecuteResultHandler() {
					@Override
					public void onProcessComplete(int exitValue) {
						configurator.getRunner().debug(logger, "OSEXEC", "External process \"" + cmdLine.toString() + "\" completed with exit value \"" + exitValue + "\"");
					}
					@Override
					public void onProcessFailed(ExecuteException e) {
						try {
							configurator.getRunner().error(logger,"External process \"" + cmdLine.toString() + "\" failed with exit value \"" + e.getExitValue() + "\"", e);
						} catch (Exception e1) {
							configurator.getRunner().fatal(logger, "External processs could not recover", e1, "TODO");
						} 
					}           
				});                
				return 0; // okay          
			} else {
				int result = executor.execute(cmdLine);        
				return result; // may be anything
			}
		} catch (Exception e) {
			logger.error("Error executing external process", e);
		}
		return 1000; // cannot execute
	}
}
