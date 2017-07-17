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
package org.mycore.opus2mycore;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.mycore.opus2mycore.transformer.RecordTransformer;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class Application {

    private static final Logger LOGGER = LogManager.getLogger();

    @Parameter(names = { "-h", "--help" }, description = "Print help (this message) and exit", help = true)
    private boolean help;

    @Parameter(names = { "-u", "--url" }, description = "The OAI base URL.")
    private String baseURL;

    @Parameter(names = { "-f", "--format" }, description = "The OAI metadata format.")
    private String format = "xMetaDissPlus";

    @Parameter(names = { "-o", "--output_dir" }, description = "The output directory.")
    private String outputDir = System.getProperty("java.io.tmpdir");

    @Parameter(names = { "-s", "--setSpec" }, description = "The OAI metadata set.")
    private String setSpec;

    @Parameter(names = { "--stylesheet" }, description = "Path to custom XSL-Stylesheet for transformation.")
    private String stylesheet;

    @Parameter(names = { "--projectId" }, description = "The MyCoRe procject id. (used for command.txt)")
    private String procjectId = "mir";

    public static void main(String[] args) {
        Application app = new Application();
        JCommander jcmd = new JCommander(app, null, args);

        if (app.help || app.baseURL == null || app.baseURL.isEmpty() || app.outputDir == null
            || app.outputDir.isEmpty()) {
            jcmd.usage();
        } else {
            try {
                app.run();
            } catch (Exception e) {
                LOGGER.error(e.getMessage(), e);
            }
        }
    }

    /**
     * @see
     * Dissertation:
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/3225
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/3178
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/3125
     *  
     * Bachelor/Master:
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/2613
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/2743
     *  
     * Schriftenreihen:
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/2699
     *  https://e-pub.uni-weimar.de/opus4/frontdoor/index/index/docId/2357
     * @throws Exception
     */
    private void run() throws Exception {
        Path outputPath = Paths.get(outputDir);
        if (!Files.exists(outputPath)) {
            Files.createDirectories(outputPath);
        }

        Path mcrCmdFile = outputPath.resolve("command.txt");
        LOGGER.info("Create MyCoRe command file {}", mcrCmdFile);
        FileOutputStream fos = new FileOutputStream(mcrCmdFile.toFile());

        try {
            XMLOutputter xmlout = new XMLOutputter(Format.getPrettyFormat());
            RecordTransformer recordTransformer = new RecordTransformer(baseURL, format, setSpec);

            recordTransformer.transformAll(stylesheet).stream()
                .filter(record -> record != null)
                .forEach(record -> {
                    try {
                        String fsRecordId = record.getRecord().getHeader().getId().replaceAll("[:.]", "_");
                        Path recordPath = outputPath.resolve(fsRecordId);
                        Path recordTransFile = recordPath.resolve(fsRecordId + ".xml");
                        Path filesPath = recordPath.resolve("files");

                        if (!Files.exists(recordPath)) {
                            Files.createDirectories(recordPath);
                        }

                        LOGGER.info("Save transformed record to {}.", recordTransFile);
                        xmlout.output(record.getDocument(), new FileOutputStream(recordTransFile.toFile()));

                        LOGGER.info("Start download of files...");
                        record.getContainer().download(filesPath);
                        LOGGER.info("download done.");

                        fos.write(String.format(Locale.ROOT,
                            "load mods document from file %s with files from directory %s for project %s\n",
                            outputPath.relativize(recordTransFile), outputPath.relativize(filesPath), procjectId)
                            .getBytes(StandardCharsets.UTF_8));
                        fos.flush();
                    } catch (IOException e) {
                        throw new UncheckedIOException(e);
                    }
                });
        } finally {
            fos.close();
        }
    }
}
