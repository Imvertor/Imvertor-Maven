// SVN: $Id: HttpFile.java 558 2015-07-10 09:07:44Z arjan $

/*
 * ====================================================================
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 *
 */

package nl.imvertor.common.file;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPHTTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.commons.net.ftp.FTPSClient;
import org.apache.commons.net.util.TrustManagerUtils;

import com.jcraft.jsch.ConfigRepository.Config;

import nl.imvertor.common.Configurator;

// see for full explanation:


public class FtpFolder {

	public boolean storeFile = false;
	public boolean binaryTransfer = false;
	public boolean xxerror = false; 
	public boolean xxlistFiles = false;
	public boolean xxlistNames = false;
	public boolean hidden = false;
	public boolean localActive = false;
	public boolean useEpsvWithIPv4 = false;
	public boolean feat = false; 
	public boolean printHash = false;
	public boolean mlst = false;
	public boolean mlsd = false;
	public boolean lenient = false;

	public int connectTimeout = -1;
	public int dataTimeout = -1;
	public int keepAliveTimeout = -1;
	public int controlKeepAliveTimeout = -1;
	public int controlKeepAliveReplyTimeout = -1;

	public int port = 0;
	
	public String server = null; 
	public String protocol = null; // SSL protocol
	public String doCommand = null;
	public String trustmgr = null;
	public String proxyHost = null;

	public int proxyPort = 80;

	public String proxyUser = null;
	public String proxyPassword = null;
	public String username = null;
	public String password = null;

	private FTPClient ftp;

	public static void main(String[] args) throws Exception {

		// FtpClient ftp = new FtpFile("tools.geostandaarden.nl", "tools", "7u&6Pvl1", -1);
		FtpFolder ftpFolder = new FtpFolder();
		
		ftpFolder.server = "tools.geostandaarden.nl";
		ftpFolder.protocol = "false";
		ftpFolder.username = "tools";
		ftpFolder.password = "7u&6Pvl1";

		ftpFolder.login();
		ftpFolder.upload("c:\\Temp\\query.xml","/respec/data/dynamic/query-2.xml");
		ftpFolder.download("/respec/data/dynamic/query-2.xml","c:\\Temp\\query-3.xml");
		ftpFolder.logout();

	}


	public FtpFolder() {
		super();
	}

	public void login() throws IOException {
	 
        String parts[] = server.split(":");
        if (parts.length == 2){
            server=parts[0];
            port=Integer.parseInt(parts[1]);
        }
    
    	if (protocol == null ) {
			if(proxyHost !=null) {
				//System.out.println("Using HTTP proxy server: " + proxyHost);
				ftp = new FTPHTTPClient(proxyHost, proxyPort, proxyUser, proxyPassword);
			}
			else {
				ftp = new FTPClient();
			}
		} else {
			FTPSClient ftps;
			if (protocol.equals("true")) {
				ftps = new FTPSClient(true);
			} else if (protocol.equals("false")) {
				ftps = new FTPSClient(false);
			} else {
				String prot[] = protocol.split(",");
				if (prot.length == 1) { // Just protocol
					ftps = new FTPSClient(protocol);
				} else { // protocol,true|false
					ftps = new FTPSClient(prot[0], Boolean.parseBoolean(prot[1]));
				}
			}
			ftp = ftps;
			if ("all".equals(trustmgr)) {
				ftps.setTrustManager(TrustManagerUtils.getAcceptAllTrustManager());
			} else if ("valid".equals(trustmgr)) {
				ftps.setTrustManager(TrustManagerUtils.getValidateServerCertificateTrustManager());
			} else if ("none".equals(trustmgr)) {
				ftps.setTrustManager(null);
			}
		}
    	
    	if (connectTimeout >= 0) {
    		ftp.setConnectTimeout(connectTimeout);
    	}
    	if (dataTimeout >= 0) {
    		ftp.setDataTimeout(dataTimeout);
    	}
    	if (keepAliveTimeout >= 0) {
    		ftp.setControlKeepAliveTimeout(keepAliveTimeout);
    	}
    	if (controlKeepAliveReplyTimeout >= 0) {
    		ftp.setControlKeepAliveReplyTimeout(controlKeepAliveReplyTimeout);
    	}
    	ftp.setListHiddenFiles(hidden);

    	// suppress login details
    	//ftp.addProtocolCommandListener(new PrintCommandListener(new PrintWriter(System.out), true));

    	try {
    		int reply;
    		if (port > 0) {
    			ftp.connect(server, port);
    		} else {
    			ftp.connect(server);
    		}
    		//System.out.println("Connected to " + server + " on " + (port>0 ? port : ftp.getDefaultPort()));

    		// After connection attempt, you should check the reply code to verify success.
    		reply = ftp.getReplyCode();

    		if (!FTPReply.isPositiveCompletion(reply)) {
    			ftp.disconnect();
    			throw new IOException("FTP server refused connection.");
    		}
    		
    	} catch (IOException e) {
    		if (ftp.isConnected()) {
    			try {
    				ftp.disconnect();
    			} catch (IOException f) {
    				// do nothing
    			}
    		}
    		throw new IOException("Could not connect to server: " + e.getMessage());
    	}
          
		if (!ftp.login(username, password)) {
			logout();
			throw new IOException("Cannot log in to this FTP");
		}
	}

	public void logout() throws IOException {
		ftp.logout();
	}
	
	public void upload(String localPath, String remotePath) throws IOException {
		initializeTransfer();
		
		File localFile = new File(localPath);
		if (localFile.isDirectory()) 
			uploadDirectory(ftp, remotePath, localPath,"");
		else 
			uploadSingleFile(ftp, remotePath, localPath);
	}

	public void download(String remotePath, String localPath) throws IOException {
		initializeTransfer();
		
	    OutputStream output;
 
        output = new FileOutputStream(localPath);

        ftp.retrieveFile(remotePath, output);

        output.close();
	}

	public FTPFile[] listFiles(String remotePath) throws IOException {
		initializeTransfer();
		
		if (lenient) {
            FTPClientConfig config = new FTPClientConfig();
            config.setLenientFutureDates(true);
            ftp.configure(config );
        }

        return ftp.listFiles(remotePath);
    }

	private void initializeTransfer() throws IOException {
		
		if (binaryTransfer) {
			ftp.setFileType(FTP.BINARY_FILE_TYPE);
		} else {
			// in theory this should not be necessary as servers should default to ASCII
			// but they don't all do so - see NET-500
			ftp.setFileType(FTP.ASCII_FILE_TYPE);
		}

		// Use passive mode as default because most of us are
		// behind firewalls these days.
		if (localActive) {
			ftp.enterLocalActiveMode();
		} else {
			ftp.enterLocalPassiveMode();
		}

		ftp.setUseEPSVwithIPv4(useEpsvWithIPv4);

	}
	
	/**
	 * Upload a whole directory (including its nested sub directories and files)
	 * to a FTP server.
	 *
	 * @param ftpClient
	 *            an instance of org.apache.commons.net.ftp.FTPClient class.
	 * @param remoteDirPath
	 *            Path of the destination directory on the server.
	 * @param localParentDir
	 *            Path of the local directory being uploaded.
	 * @param remoteParentDir
	 *            Path of the parent directory of the current directory on the
	 *            server (used by recursive calls).
	 * @throws IOException
	 *             if any network or IO error occurred.
	 */
	public void uploadDirectory(FTPClient ftpClient, String remoteDirPath, String localParentDir, String remoteParentDir)
	        throws IOException {
	 
	    File localDir = new File(localParentDir);
	    File[] subFiles = localDir.listFiles();
	    if (subFiles != null && subFiles.length > 0) {
	        for (File item : subFiles) {
	            String remoteFilePath = remoteDirPath + "/" + remoteParentDir + "/" + item.getName();
	            if (remoteParentDir.equals("")) 
	                remoteFilePath = remoteDirPath + "/" + item.getName();
	            
	            if (item.isFile()) {
	                // upload the file
	                String localFilePath = item.getAbsolutePath();
	                boolean uploaded = uploadSingleFile(ftpClient, localFilePath, remoteFilePath);
	                if (!uploaded) 
	                    throw new IOException("Cannot upload to " + remoteFilePath);
	            } else {
	                // create directory on the server
	            	removeRemoteFolder(ftpClient,remoteFilePath);
	            	ftpClient.removeDirectory(remoteFilePath); // may succeed or not. 
	            	boolean created = ftpClient.makeDirectory(remoteFilePath);
	                if (!created) 
	                    throw new IOException("Cannot create remote folder " + remoteFilePath);
	     	       
	                // upload the sub directory
	                String parent = remoteParentDir + "/" + item.getName();
	                if (remoteParentDir.equals("")) 
	                    parent = item.getName();
	               
	                localParentDir = item.getAbsolutePath();
	                uploadDirectory(ftpClient, remoteDirPath, localParentDir, parent);
	            }
	        }
	    }
	}
	/**
	 * Upload a single file to the FTP server.
	 *
	 * @param ftpClient
	 *            an instance of org.apache.commons.net.ftp.FTPClient class.
	 * @param localFilePath
	 *            Path of the file on local computer
	 * @param remoteFilePath
	 *            Path of the file on remote the server
	 * @return true if the file was uploaded successfully, false otherwise
	 * @throws IOException
	 *             if any network or IO error occurred.
	 */
	public boolean uploadSingleFile(FTPClient ftpClient, String localFilePath, String remoteFilePath) throws IOException {
	    File localFile = new File(localFilePath);
	 
	    InputStream inputStream = new FileInputStream(localFile);
	    try {
	        ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
	        return ftpClient.storeFile(remoteFilePath, inputStream);
	    } finally {
	        inputStream.close();
	    }
	}
	
	// from: https://stackoverflow.com/questions/23768703/how-to-delete-directory-using-java-after-uploading-files-to-remote-server
	public void removeRemoteFolder(FTPClient ftpClient, String remotePath) throws IOException {
	    FTPFile[] files=ftpClient.listFiles(remotePath);
		if(files.length>0) {
	        for (FTPFile ftpFile : files) {
	            if(ftpFile.isDirectory())
	            	removeRemoteFolder(ftpClient, remotePath + "/" + ftpFile.getName());
	            else {
	                String deleteFilePath = remotePath + "/" + ftpFile.getName();
	                ftpClient.deleteFile(deleteFilePath);
	            }
	        }
	    }
        ftpClient.removeDirectory(remotePath);
	}
}
