package nl.imvertor.common.git;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.PullResult;
import org.eclipse.jgit.transport.PushResult;
import org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Runner;

/**
 * Pushes all files from a local directory to a remote git repository
 * 
 * @author Maarten Kroon
 */
public class ResourcePusher {

	protected static final Logger logger = Logger.getLogger(ResourcePusher.class);

	private String remoteRepositoryURI;
	private File localWorkDir;
	private String user;
	private String pass;
	private String token;
	private String email;
	private Git git;
	private boolean gitopen = false;

	private Runner runner = Configurator.getInstance().getRunner();
	
	/**
	 * Pushes all files from a local directory to a remote git repository
	 * 
	 * @param remoteRepositoryURI
	 *          the URI of the remote repository to push the files to

	 * @param localWorkDir
	 *          the local work directory; if the local repository already exists
	 *          it is (re)used as is, otherwise it is cloned from the remote repository
	 * @param srcDir
	 *          the directory containing the files that must be pushed. The complete
	 *          directory structure is pushed to the remote repository
	 * @param commitMessage
	 *          the message which is used to commit to the local repository
	 * @return a list of JGit PushResults (typically 1)
	 * @throws Exception
	 */
	public Iterable<PushResult> push(String commitMessage) throws Exception {

		//Runner runner = Configurator.getInstance().getRunner();

		if (!gitopen) git = Git.open(localWorkDir);

		try {
			runner.debug(logger, "GITHUB", "Adding files to local repository ...");
			/* Add the source files (that were not already added) to the repository: */
			git.add()
				.addFilepattern(".")
				.call();

			runner.debug(logger, "GITHUB", "Committing files to local repository ...");
			/* Commit the files to the repository: */
			git.commit()
				.setMessage(commitMessage)
				.setCommitter(user, email)
				.setAuthor(user, email)
			 	.call();
			
			runner.debug(logger, "GITHUB", "Pushing files to remote repository \"" + remoteRepositoryURI + "\" ...");
			/* Push all changes to the remote server: */
			
			UsernamePasswordCredentialsProvider cred;
			if (token != null) 
				cred = new UsernamePasswordCredentialsProvider(token, ""); // https://stackoverflow.com/questions/28073266/how-to-use-jgit-to-push-changes-to-remote-with-oauth-access-token
			else 
				cred = new UsernamePasswordCredentialsProvider(user, pass);
	
			return git.push()
				.setCredentialsProvider(cred) 
				.call();

		} finally {
			git.close();
		}
	}

	/**
	 * Pushes all files from a local directory to a remote git repository
	 * 
	 * @param remoteRepositoryURI
	 *          the URI of the remote repository to push the files to
	 * @param localWorkDir
	 *          the local work directory; if the local repository already exists
	 *          it is (re)used as is, otherwise it is cloned from the remote repository
	 * @param srcDir
	 *          the directory containing the files that must be pushed. The complete
	 *          directory structure is pushed to the remote repository
	 * @param commitMessage
	 *          the message which is used to commit to the local repository
	 * @return a list of JGit PushResults (typically 1)
	 * @throws Exception
	 */

	public Iterable<PushResult> push(File srcDir, String commitMessage) throws Exception {

		//Runner runner = Configurator.getInstance().getRunner();

		runner.debug(logger, "GITHUB", "Copying files from the source directory \"" + localWorkDir.getAbsolutePath() + "\" to local work directory ...");
		/* Copy the source files over the local repository */
		FileUtils.copyDirectory(srcDir, localWorkDir);

		return push(commitMessage);

	}

	/**
	 * Prepares a local directory to serve as a git repository
	 * 
	 * @param remoteRepositoryURI
	 *          the URI of the remote repository to push the files to
	 * @param localWorkDir
	 *          the local work directory; if the local repository already exists
	 *          it is (re)used as is, otherwise it is cloned from the remote repository
	 * @param username
	 *          username to login to remote repository
	 * @param password
	 *          password to login to remote repository 
	 * @param removeLocalWorkDir
	 *          remove existing local work directory first, which means a clone of the
	 *          repository is forced instead of a pull
	 * @throws Exception
	 */
	public void prepare(String remoteRepositoryURI, File localWorkDir, String username, String password, String token, String email, boolean removeLocalWorkDir) throws Exception {

		//Runner runner = Configurator.getInstance().getRunner();

		this.remoteRepositoryURI = remoteRepositoryURI;
		this.localWorkDir = localWorkDir;
		this.user = username;
		this.pass = password;
		this.token = token;
		this.email = email;
		
		/* Optionally remove the local work directory first: */
		if (localWorkDir.exists() && removeLocalWorkDir) {
			org.eclipse.jgit.util.FileUtils.delete(localWorkDir,org.eclipse.jgit.util.FileUtils.RECURSIVE);
			runner.debug(logger, "GITHUB", "Local workdir removed? " + (localWorkDir.list() == null));
		}

		/* Make sure localWorkDir exists: */
		if (!localWorkDir.isDirectory() && !localWorkDir.mkdirs())
			throw new IOException("Could not create local work directory \"" + localWorkDir.getAbsolutePath() + "\"");

		/* Create the Git instance: */
		File gitFile = new File(localWorkDir, ".git");
		if (!gitFile.isDirectory()) {
			runner.debug(logger, "GITHUB", "Cloning remote git repository \"" + remoteRepositoryURI + "\" to local work directory \"" + localWorkDir.getAbsolutePath() + "\" ...");

			/* Local work directory does not exists; clone remot repository: */
			FileUtils.cleanDirectory(localWorkDir);
			git = Git.cloneRepository()
					.setURI(remoteRepositoryURI)
					.setDirectory(localWorkDir)
					.call();
		} else if (!gitopen) {
			runner.debug(logger, "GITHUB", "Opening existing local repository \"" + localWorkDir.getAbsolutePath() + "\" ...");
			/* Open the existing local repository: */
			git = Git.open(localWorkDir);
			
			runner.debug(logger, "GITHUB", "Pulling latest files to local repository ...");
			/* Pull latest remote changes: */
			PullResult pullResult = git.pull().call();
		  if (pullResult.isSuccessful()) {
		    runner.debug(logger, "GITHUB", "Pull successful");
		  } else {
		    if (!FileUtils.deleteQuietly(localWorkDir)) {
		      runner.warn(logger, String.format("Could not remove directory \"%s\"", localWorkDir.getAbsolutePath()));
		    }
		    throw new IOException("Error pulling latest files from repository: " + pullResult.toString());
		  }
			
		}
		gitopen = true;
	}

}