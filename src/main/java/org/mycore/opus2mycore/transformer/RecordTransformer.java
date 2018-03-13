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
package org.mycore.opus2mycore.transformer;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.transform.JDOMResult;
import org.jdom2.transform.JDOMSource;
import org.mycore.oai.pmh.BadArgumentException;
import org.mycore.oai.pmh.BadResumptionTokenException;
import org.mycore.oai.pmh.CannotDisseminateFormatException;
import org.mycore.oai.pmh.Header;
import org.mycore.oai.pmh.IdDoesNotExistException;
import org.mycore.oai.pmh.NoRecordsMatchException;
import org.mycore.oai.pmh.NoSetHierarchyException;
import org.mycore.oai.pmh.Record;
import org.mycore.oai.pmh.harvester.HarvestException;
import org.mycore.oai.pmh.harvester.Harvester;
import org.mycore.oai.pmh.harvester.HarvesterBuilder;
import org.mycore.oai.pmh.harvester.HarvesterUtil;
import org.mycore.opus2mycore.entity.OAIFileContainer;
import org.mycore.opus2mycore.entity.OAIRecord;

/**
 * @author Ren\u00E9 Adler (eagle)
 *
 */
public class RecordTransformer {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String DEFAULT_FORMAT = "oai_dc";

    private static TransformerFactory factory = TransformerFactory.newInstance();

    private final String baseURL;

    private String format;

    private String setSpec;

    private Harvester harvester;

    private Function<String, String> formatFunc = (format) -> {
        if (format == null || !harvester.listMetadataFormats().stream().anyMatch(mf -> mf.getPrefix().equals(format))) {
            LOGGER.warn("Metadata format \"{}\" isn't supported fallback to default format (\"{}\").", format,
                DEFAULT_FORMAT);
            return DEFAULT_FORMAT;
        } else {
            return format;
        }
    };

    public RecordTransformer(String baseURL) {
        this(baseURL, null);
    }

    public RecordTransformer(String baseURL, String format) {
        this(baseURL, format, null);
    }

    public RecordTransformer(String baseURL, String format, String setSpec) {
        this(baseURL, format, setSpec, true);
    }

    public RecordTransformer(String baseURL, String format, String setSpec, boolean skipFormatCheck) {
        this.baseURL = baseURL;
        this.setSpec = setSpec;
        harvester = HarvesterBuilder.createNewInstance(this.baseURL);
        this.format = !skipFormatCheck ? formatFunc.apply(format) : format;
    }

    public OAIRecord transform(String id) throws BadArgumentException, CannotDisseminateFormatException,
        NoRecordsMatchException, NoSetHierarchyException, HarvestException, IdDoesNotExistException,
        MalformedURLException {
        return transform(id, null);
    }

    public OAIRecord transform(String id, String stylesheet)
        throws BadArgumentException, CannotDisseminateFormatException, NoRecordsMatchException,
        NoSetHierarchyException, HarvestException, IdDoesNotExistException, MalformedURLException {

        Record r = harvester.getRecord(id, format);

        if (r.getMetadata() == null) {
            LOGGER.warn("No metadata found for record with id {}.", id);
            return null;
        }

        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug((new XMLOutputter(Format.getPrettyFormat())).outputString(r.getMetadata().toXML()));
        }

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("recordBaseURL", baseURL);
            params.put("recordId", id);

            JDOMResult result = transform(r.getMetadata().toXML(),
                Optional.ofNullable(stylesheet).orElse("/transformer/" + format + ".xsl"), params);

            OAIRecord record = new OAIRecord(r);
            record.setDocument(result.getDocument());
            record.setContainer(OAIFileContainer.parse(r, format));

            return record;
        } catch (TransformerException | IOException e) {
            throw new IllegalArgumentException(
                "Couldn't transform metadata with provided xsl stylesheet ("
                    + Optional.ofNullable(stylesheet).orElse("/transformer/" + format + ".xsl") + ").",
                e);
        }
    }

    public List<OAIRecord> transformAll() throws BadArgumentException, CannotDisseminateFormatException,
        NoRecordsMatchException, NoSetHierarchyException, HarvestException, BadResumptionTokenException {
        return transformAll(null);
    }

    public List<OAIRecord> transformAll(String stylesheet)
        throws BadArgumentException, CannotDisseminateFormatException, NoRecordsMatchException,
        NoSetHierarchyException, HarvestException, BadResumptionTokenException {

        return processRecords(HarvesterUtil.streamHeaders(harvester, format, null, null, setSpec), stylesheet);
    }

    private JDOMResult transform(Element xml, String stylesheet, Map<String, Object> params)
        throws TransformerException, IOException {
        InputStream xis = getClass().getResourceAsStream(stylesheet);
        if (xis == null) {
            xis = new FileInputStream(new File(stylesheet));
        }

        Source xslt = new StreamSource(xis);
        Transformer transformer = factory.newTransformer(xslt);
        Optional.ofNullable(params)
            .ifPresent(p -> p.entrySet().forEach(e -> transformer.setParameter(e.getKey(), e.getValue())));
        JDOMResult result = new JDOMResult();
        transformer.transform(new JDOMSource(xml), result);

        xis.close();

        return result;
    }

    private List<OAIRecord> processRecords(Stream<Header> recordStream, String stylesheet) {
        return recordStream.parallel().map(h -> {
            try {
                return this.transform(h.getId(), stylesheet);
            } catch (BadArgumentException | CannotDisseminateFormatException | NoRecordsMatchException
                | NoSetHierarchyException | HarvestException | IdDoesNotExistException | MalformedURLException e) {
                throw new IllegalArgumentException(e.getMessage(), e);
            }
        }).collect(Collectors.toList());
    }
}
