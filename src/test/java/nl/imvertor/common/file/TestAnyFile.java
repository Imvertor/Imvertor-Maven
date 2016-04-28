package nl.imvertor.common.file;

import org.junit.Assert;
import org.junit.Test;

import nl.imvertor.common.file.AnyFile;

public class TestAnyFile {

    @Test
    public void ShouldBeAbsolute() {
	Assert.assertTrue(AnyFile.isAbsolutePath("/dsfsdf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("\\dsfdsf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("x:gfhfghgf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("/"));
	Assert.assertTrue(AnyFile.isAbsolutePath("\\"));
	Assert.assertTrue(AnyFile.isAbsolutePath("x:"));
	Assert.assertTrue(AnyFile.isAbsolutePath("a:"));
    }

    @Test
    public void ShouldNotBeAbsolute() {
	Assert.assertTrue(AnyFile.isAbsolutePath("dsfsdf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("ds\\fdsf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("gf/hfghgf"));
	Assert.assertTrue(AnyFile.isAbsolutePath("gf/hfghgf/"));
	Assert.assertTrue(AnyFile.isAbsolutePath("gf\\hfghgf\\"));
    }

}
