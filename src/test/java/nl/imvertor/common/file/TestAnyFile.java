package nl.imvertor.common.file;

import org.junit.Assert;
import org.junit.Test;

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
	Assert.assertFalse(AnyFile.isAbsolutePath("dsfsdf"));
	Assert.assertFalse(AnyFile.isAbsolutePath("ds\\fdsf"));
	Assert.assertFalse(AnyFile.isAbsolutePath("gf/hfghgf"));
	Assert.assertFalse(AnyFile.isAbsolutePath("gf/hfghgf/"));
	Assert.assertFalse(AnyFile.isAbsolutePath("gf\\hfghgf\\"));
    }

}
