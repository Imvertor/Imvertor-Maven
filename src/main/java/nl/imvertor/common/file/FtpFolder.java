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

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;

import org.apache.commons.net.PrintCommandListener;
import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPHTTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.commons.net.ftp.FTPSClient;
import org.apache.commons.net.util.TrustManagerUtils;

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

	public long keepAliveTimeout = -1;

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
    		throw new IOException("Could not connect to server.");
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
		
		InputStream input;

		input = new FileInputStream(localPath);

		ftp.storeFile(remotePath, input);

		input.close();
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
}
