<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:cc="http://www.d-nb.de/standards/cc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:ddb="http://www.d-nb.de/standards/ddb/" xmlns:pc="http://www.d-nb.de/standards/pc/" xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
  xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xsl exsl cc dc dcmitype dcterms ddb pc thesis xMetaDiss"
>

  <xsl:param name="recordBaseURL" select="''" />
  <xsl:param name="recordId" select="''" />

  <xsl:param name="allowFreeSubject" select="false()" />

  <xsl:variable name="rfc4646" select="document('http://www.mycore.org/classifications/rfc4646.xml')/mycoreclass" />
  <xsl:variable name="mir_genres" select="document('http://www.mycore.org/classifications/mir_genres.xml')/mycoreclass" />
  <xsl:variable name="mir_licenses" select="document('http://www.mycore.org/classifications/mir_licenses.xml')/mycoreclass" />

  <xsl:template match="xMetaDiss:xMetaDiss">
    <mods xmlns="http://www.loc.gov/mods/v3">
      <xsl:apply-templates />
      <xsl:if test="string-length($recordId) &gt; 0">
        <identifier type="oai" typeURI="{$recordBaseURL}">
          <xsl:value-of select="$recordId" />
        </identifier>
      </xsl:if>
      <xsl:call-template name="originInfo" />
    </mods>
  </xsl:template>

  <xsl:template match="*">
  </xsl:template>

  <xsl:template match="dc:language[@xsi:type='dcterms:ISO639-2']">
    <language>
      <languageTerm authority="rfc4646" type="code">
        <xsl:call-template name="langCode">
          <xsl:with-param name="code" select="." />
        </xsl:call-template>
      </languageTerm>
    </language>
  </xsl:template>

  <xsl:template match="dc:title">
    <titleInfo xlink:type="simple">
      <xsl:attribute name="xml:lang">
        <xsl:call-template name="langCode">
          <xsl:with-param name="code" select="@lang" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:if test="../dc:language[@xsi:type='dcterms:ISO639-2'] != @lang">
        <xsl:attribute name="type">
          <xsl:text>translated</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <title>
        <xsl:value-of select="." />
      </title>
    </titleInfo>
  </xsl:template>

  <xsl:template match="dc:creator">
    <xsl:for-each select="pc:person/pc:name[@type='nameUsedByThePerson']">
      <name type="personal" xlink:type="simple">
        <displayForm>
          <xsl:value-of select="pc:surName" />
          <xsl:text>, </xsl:text>
          <xsl:value-of select="pc:foreName" />
        </displayForm>
        <role>
          <roleTerm authority="marcrelator" type="code">aut</roleTerm>
        </role>
        <namePart type="family">
          <xsl:value-of select="pc:surName" />
        </namePart>
        <namePart type="given">
          <xsl:value-of select="pc:foreName" />
        </namePart>
      </name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dc:contributor">
    <xsl:variable name="role">
      <xsl:choose>
        <xsl:when test="@thesis:role = 'advisor'">
          <xsl:text>ths</xsl:text>
        </xsl:when>
        <xsl:when test="@thesis:role = 'referee'">
          <xsl:text>rev</xsl:text>
        </xsl:when>
        <xsl:when test="@thesis:role = 'editor'">
          <xsl:text>edt</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>oth</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="pc:person/pc:name[@type='nameUsedByThePerson']">
      <name type="personal" xlink:type="simple">
        <displayForm>
          <xsl:value-of select="pc:surName" />
          <xsl:text>, </xsl:text>
          <xsl:value-of select="pc:foreName" />
        </displayForm>
        <role>
          <roleTerm authority="marcrelator" type="code">
            <xsl:value-of select="$role" />
          </roleTerm>
        </role>
        <namePart type="family">
          <xsl:value-of select="pc:surName" />
        </namePart>
        <namePart type="given">
          <xsl:value-of select="pc:foreName" />
        </namePart>
      </name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dc:publisher">
    <xsl:for-each select="cc:universityOrInstitution">
      <name type="corporate" xlink:type="simple">
        <xsl:for-each select="cc:name[string-length(text()) &gt; 0]">
          <displayForm>
            <xsl:value-of select="." />
          </displayForm>
          <namePart>
            <xsl:value-of select="." />
          </namePart>
        </xsl:for-each>
        <role>
          <roleTerm type="code" authority="marcrelator">edt</roleTerm>
        </role>
      </name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dc:identifier[@xsi:type='urn:nbn']">
    <identifier type="urn">
      <xsl:value-of select="." />
    </identifier>
  </xsl:template>

  <xsl:template match="dc:subject[@xsi:type='xMetaDiss:DDC-SG']">
    <classification displayLabel="sdnb" authority="sdnb">
      <xsl:value-of select="." />
    </classification>
  </xsl:template>

  <xsl:template match="dc:subject[@xsi:type='xMetaDiss:SWD']">
    <subject xlink:type="simple">
      <topic>
        <xsl:value-of select="." />
      </topic>
    </subject>
  </xsl:template>

  <xsl:template match="dc:subject[@xsi:type='xMetaDiss:noScheme']">
    <xsl:if test="$allowFreeSubject = 'true'">
      <subject xlink:type="simple">
        <topic>
          <xsl:value-of select="." />
        </topic>
      </subject>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dc:type[@xsi:type='dini:PublType']">
    <xsl:variable name="publType">
      <xsl:choose>
        <xsl:when test="string-length(../thesis:degree/thesis:level) &gt; 0">
          <xsl:value-of select="../thesis:degree/thesis:level" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="genre">
      <xsl:call-template name="diniPublType2genre">
        <xsl:with-param name="publType" select="$publType" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="string-length($genre) &gt; 0">
      <genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres" valueURI="http://www.mycore.org/classifications/mir_genres#{$genre}" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="dc:rights">
    <xsl:variable name="rparts">
      <xsl:call-template name="splitString">
        <xsl:with-param name="separator" select="'-'" />
        <xsl:with-param name="str" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="firstPart" select="exsl:node-set($rparts)/part[1]" />

    <xsl:variable name="possibleLicense">
      <xsl:for-each select="$mir_licenses/categories/category[label[contains(@text, $firstPart) or contains(@description, $firstPart)]]/category">
        <xsl:for-each select="label">
          <xsl:variable name="description" select="@description" />
          <xsl:variable name="numDescriptionParts">
            <xsl:variable name="parts">
              <xsl:call-template name="splitString">
                <xsl:with-param name="separator" select="'-'" />
                <xsl:with-param name="str" select="$description" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="count(exsl:node-set($parts)/part)" />
          </xsl:variable>
          <xsl:variable name="matching">
            <xsl:for-each select="exsl:node-set($rparts)/part[not(position() = 1)]">
              <xsl:variable name="m">
                <xsl:call-template name="containsPhrase">
                  <xsl:with-param name="separator" select="'-'" />
                  <xsl:with-param name="str" select="$description" />
                  <xsl:with-param name="phrase" select="." />
                  <xsl:with-param name="exact" select="false()" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:if test="$m = 'true'">
                <part />
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="possibility">
            <xsl:value-of select="round(100 div count(exsl:node-set($rparts)/part[not(position() = 1)]) * count(exsl:node-set($matching)/part))" />
          </xsl:variable>

          <xsl:if test="($numDescriptionParts = count(exsl:node-set($rparts)/part[not(position() = 1)])) and ($possibility &gt; 80)">
            <!--
            <xsl:message>
              ID:
              <xsl:value-of select="../@ID" />
              description:
              <xsl:value-of select="$description" />
              numDescriptionParts:
              <xsl:value-of select="$numDescriptionParts" />
              rparts:
              <xsl:value-of select="count(exsl:node-set($rparts)/part[not(position() = 1)])" />
              numMatching:
              <xsl:value-of select="count(exsl:node-set($matching)/part)" />
              possibility:
              <xsl:value-of select="$possibility" />
            </xsl:message>
            -->
            <p percent="{$possibility}">
              <xsl:copy-of select=".." />
            </p>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="exsl:node-set($possibleLicense)/p">
      <xsl:sort select="percent" data-type="number" order="descending" />
      <xsl:sort select="category/@ID" data-type="text" order="descending" />
      <xsl:if test="position() = 1">
        <!--
        <xsl:message>
          possibleLicense:
          
          percent:
          <xsl:value-of select="@percent" />
          description:
          <xsl:value-of select="category/@ID" />
        </xsl:message>
        -->
        <accessCondition type="use and reproduction" xlink:href="http://www.mycore.org/classifications/mir_licenses#{category/@ID}" xlink:type="simple" />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dcterms:abstract">
    <abstract xlink:type="simple">
      <xsl:attribute name="xml:lang">
        <xsl:call-template name="langCode">
          <xsl:with-param name="code" select="@lang" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="." />
    </abstract>
  </xsl:template>

  <xsl:template match="dcterms:isPartOf[@xsi:type='ddb:noScheme']">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="contains(., ';')">
          <xsl:value-of select="normalize-space(substring-before(., ';'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="volume">
      <xsl:if test="contains(., ';')">
        <xsl:value-of select="normalize-space(substring-after(., ';'))" />
      </xsl:if>
    </xsl:variable>

    <xsl:if test="string-length($title) &gt; 0">
      <relatedItem type="series" xlink:type="simple">
        <xsl:if test="string-length($title) &gt; 0">
          <titleInfo>
            <title>
              <xsl:value-of select="$title" />
            </title>
          </titleInfo>
        </xsl:if>
        <xsl:if test="string-length($volume) &gt; 0">
          <part>
            <detail type="volume">
              <number>
                <xsl:value-of select="$volume" />
              </number>
            </detail>
          </part>
        </xsl:if>
      </relatedItem>
    </xsl:if>
  </xsl:template>

  <xsl:template match="thesis:degree">
    <xsl:for-each select="thesis:grantor[@xsi:type='cc:Corporate']/cc:universityOrInstitution">
      <name type="corporate" xlink:type="simple">
        <xsl:for-each select="cc:name[string-length(text()) &gt; 0]">
          <displayForm>
            <xsl:value-of select="." />
          </displayForm>
          <namePart>
            <xsl:value-of select="." />
          </namePart>
        </xsl:for-each>
        <role>
          <roleTerm authority="marcrelator" type="code">his</roleTerm>
        </role>
      </name>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="langCode">
    <xsl:param name="code" select="'ger'" />

    <xsl:value-of select="$rfc4646//label[@xml:lang='x-bibl' and @text=$code]/../@ID" />
  </xsl:template>

  <xsl:template name="diniPublType2genre">
    <xsl:param name="publType" select="'Other'" />

    <xsl:choose>
      <xsl:when test="$mir_genres//category[@ID=$publType]">
        <xsl:value-of select="." />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="genres">
          <xsl:for-each
            select="$mir_genres//label[@xml:lang='x-mapping' and (contains(@text, concat('diniPublType:', $publType)) or contains(@text, concat('XMetaDissPlusThesisLevel:', $publType)))]"
          >
            <xsl:choose>
              <xsl:when test="contains(@text, ' ')">
                <xsl:variable name="isMatching">
                  <xsl:variable name="mDini">
                    <xsl:call-template name="containsPhrase">
                      <xsl:with-param name="str" select="@text" />
                      <xsl:with-param name="phrase" select="concat('diniPublType:', $publType)" />
                    </xsl:call-template>
                  </xsl:variable>

                  <xsl:choose>
                    <xsl:when test="$mDini = 'true'">
                      <xsl:value-of select="true()" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="containsPhrase">
                        <xsl:with-param name="str" select="@text" />
                        <xsl:with-param name="phrase" select="concat('XMetaDissPlusThesisLevel:', $publType)" />
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:if test="$isMatching = 'true'">
                  <xsl:copy-of select=".." />
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select=".." />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="exsl:node-set($genres)/category[position() = last()]">
          <xsl:value-of select="@ID" />
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="originInfo">
    <!-- creation -->
    <xsl:if test="dcterms:issued[@xsi:type='dcterms:W3CDTF'] or dcterms:dateAccepted[@xsi:type='dcterms:W3CDTF']">
      <originInfo eventType="creation">
        <xsl:if test="dcterms:issued[@xsi:type='dcterms:W3CDTF']">
          <dateIssued encoding="w3cdtf">
            <xsl:value-of select="dcterms:issued[@xsi:type='dcterms:W3CDTF']" />
          </dateIssued>
        </xsl:if>
        <xsl:if test="dcterms:dateAccepted[@xsi:type='dcterms:W3CDTF']">
          <dateOther type="accepted" encoding="w3cdtf">
            <xsl:value-of select="dcterms:dateAccepted[@xsi:type='dcterms:W3CDTF']" />
          </dateOther>
        </xsl:if>
      </originInfo>
    </xsl:if>
    <!-- publication -->
    <originInfo eventType="publication">
      <xsl:if test="dcterms:issued[@xsi:type='dcterms:W3CDTF']">
        <dateIssued encoding="w3cdtf">
          <xsl:value-of select="dcterms:issued[@xsi:type='dcterms:W3CDTF']" />
        </dateIssued>
      </xsl:if>
    </originInfo>
  </xsl:template>

  <!-- HELPER -->

  <xsl:template name="splitString">
    <xsl:param name="separator" select="' '" />
    <xsl:param name="str" />

    <xsl:variable name="tmp" select="substring-before($str, $separator)" />
    <xsl:choose>
      <xsl:when test="(string-length($tmp) = 0) and (string-length($str) &gt; 0)">
        <part>
          <xsl:value-of select="normalize-space($str)" />
        </part>
      </xsl:when>
      <xsl:when test="(string-length($tmp) &gt; 0)">
        <part>
          <xsl:value-of select="normalize-space($tmp)" />
        </part>
      </xsl:when>
    </xsl:choose>

    <xsl:variable name="next" select="substring-after($str, $separator)" />
    <xsl:if test="string-length($next) &gt; 0">
      <xsl:call-template name="splitString">
        <xsl:with-param name="separator" select="$separator" />
        <xsl:with-param name="str" select="$next" />
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <xsl:template name="containsPhrase">
    <xsl:param name="separator" select="' '" />
    <xsl:param name="str" />
    <xsl:param name="phrase" />
    <xsl:param name="exact" select="true()" />

    <!--
    <xsl:message>
      str:
      <xsl:value-of select="$str" />
      phrase:
      <xsl:value-of select="$phrase" />
      exact:
      <xsl:value-of select="$exact" />
    </xsl:message>
    -->

    <xsl:variable name="tmp" select="normalize-space(substring-before($str, $separator))" />

    <xsl:choose>
      <xsl:when test="(string-length($str) &gt; 0) and ((($str = $phrase) and $exact) or (contains($str, $phrase) and not($exact)))">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:when test="(string-length($tmp) &gt; 0) and ((($tmp = $phrase) and $exact) or (contains($tmp, $phrase) and not($exact)))">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next" select="normalize-space(substring-after($str, $separator))" />
        <xsl:choose>
          <xsl:when test="string-length($next) = 0">
            <xsl:value-of select="false()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="containsPhrase">
              <xsl:with-param name="separator" select="$separator" />
              <xsl:with-param name="str" select="$next" />
              <xsl:with-param name="phrase" select="$phrase" />
              <xsl:with-param name="exact" select="$exact" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>