/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */
package org.mycore.opus2mycore.utils;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.commons.compress.archivers.ArchiveException;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.utils.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * The Class ArchiveUtils.
 *
 * @author Ren\u00E9 Adler (eagle)
 */
public class ArchiveUtils {

    /** The Constant LOGGER. */
    private static final Logger LOGGER = LogManager.getLogger();

    /**
     * Check if input file a tar archive.
     *
     * @param inputFile the input file
     * @return <code>true</code> if a tar archive.
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public static boolean isTar(Path inputFile) throws IOException {
        InputStream fis = new FileInputStream(inputFile.toFile());
        TarArchiveInputStream tis = null;
        try {
            tis = (TarArchiveInputStream) new ArchiveStreamFactory()
                .createArchiveInputStream("tar", fis);
            return tis.getNextEntry() != null;
        } catch (ArchiveException e) {
            return false;
        } finally {
            if (tis != null) {
                tis.close();
            }
        }
    }

    /**
     * Checks if input file a zip archive.
     *
     * @param inputFile the input file
     * @return <code>true</code> if a zip archive
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public static boolean isZip(Path inputFile) throws IOException {
        ZipInputStream zis = null;
        try {
            zis = new ZipInputStream(new FileInputStream(inputFile.toFile()));
            return zis.getNextEntry() != null;
        } finally {
            if (zis != null) {
                zis.close();
            }
        }
    }

    /**
     * Extract a tar archive.
     *
     * @param inputFile the input file
     * @param outputDir the output dir
     * @return the list
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public static List<Path> extractTar(Path inputFile, Path outputDir) throws IOException {
        InputStream fis = new FileInputStream(inputFile.toFile());
        TarArchiveInputStream tis = null;
        try {
            List<Path> extractedFiles = new LinkedList<>();
            tis = (TarArchiveInputStream) new ArchiveStreamFactory()
                .createArchiveInputStream("tar", fis);

            TarArchiveEntry entry = null;
            while ((entry = (TarArchiveEntry) tis.getNextEntry()) != null) {
                Path outputFile = outputDir.resolve(entry.getName());
                if (entry.isDirectory()) {
                    if (!Files.exists(outputFile)) {
                        Files.createDirectories(outputFile);
                    }
                } else {
                    LOGGER.info("Extract file {}.", outputFile);
                    final OutputStream ofis = new FileOutputStream(outputFile.toFile());
                    IOUtils.copy(tis, ofis);
                    ofis.close();
                }
                extractedFiles.add(outputFile);
            }

            return extractedFiles;
        } catch (ArchiveException e) {
            throw new IOException(e.getMessage(), e);
        } finally {
            if (tis != null) {
                tis.close();
            }
        }
    }

    /**
     * Extract a zip archive.
     *
     * @param inputFile the input file
     * @param outputDir the output dir
     * @return the list
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public static List<Path> extractZip(Path inputFile, Path outputDir) throws IOException {
        ZipInputStream zis = null;
        try {
            List<Path> extractedFiles = new LinkedList<>();
            zis = new ZipInputStream(new FileInputStream(inputFile.toFile()));
            ZipEntry entry = null;
            while ((entry = zis.getNextEntry()) != null) {
                Path outputFile = outputDir.resolve(entry.getName());
                if (entry.isDirectory()) {
                    if (!Files.exists(outputFile)) {
                        Files.createDirectories(outputFile);
                    }
                } else {
                    LOGGER.info("Extract file {}.", outputFile);
                    final OutputStream ofis = new FileOutputStream(outputFile.toFile());
                    IOUtils.copy(zis, ofis);
                    ofis.close();
                }
                extractedFiles.add(outputFile);
            }

            return extractedFiles;
        } finally {
            if (zis != null) {
                zis.close();
            }
        }
    }

}
