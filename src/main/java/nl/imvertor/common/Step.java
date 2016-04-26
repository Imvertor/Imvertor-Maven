/*
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package nl.imvertor.common;

import nl.imvertor.common.xsl.extensions.ImvertorParseHTML;

/**
 * A step is a class that is runnable, and is able to report on the run. 
 * 
 * All steps inherit a protected configurator and runner.
 * 
 * @author arjan
 *
 */
public class Step {

	protected Configurator configurator = Configurator.getInstance();
	protected Runner runner = configurator.getRunner();
	
	public boolean run() throws Exception {
		throw new Exception("Step run not implemented.");
	}

	/**
	 * Default implementation of reporting.
	 * This method compiles a XML documentation fragment file [stepname]-report.xml, based on the current configuration and 
	 * the step reporting stylesheet ([stepname]-report.xsl).
	 * 
	 * @return
	 * @throws Exception
	 */
	public boolean report(Transformer transformer) throws Exception {
		// create a transformer
		String sn = configurator.getActiveStepName();
		String infile = configurator.getConfigFilepath(); 
		String outfile = configurator.getParm("system","work-rep-folder-path") + "/" + sn + "-report.xml"; 
		String xslfile = configurator.getParm("system","xsl-folder-path") + "/" + sn + "/" + sn + "-report.xsl"; 
		return transformer.transform(infile,outfile,xslfile);
	}
	
	/**
	 * Report by using a default transformer.
	 * 
	 * See report(Transformer transformer)
	 * 
	 * @return
	 * @throws Exception
	 */
	public boolean report() throws Exception {
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorParseHTML());
		return report(transformer);
	}
		
	public void prepare() throws Exception {
		configurator.prepareStep();
	}
	
}
