<?xml version='1.0'?>
<xsl:stylesheet version="2.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
				xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
				xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
				xmlns:dct="http://purl.org/dc/terms/"
				xmlns:htrc="http://wcsa.htrc.illinois.edu/"
				xmlns:ext="http://exslt.org/common">

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" />

<xsl:key name="lang_combined" match="." use="." />
<xsl:param name="output_path" />
<xsl:param name="pPat">"</xsl:param>
<xsl:param name="pRep">\\"</xsl:param>
<xsl:param name="oneSlash">\\</xsl:param>
<xsl:param name="twoSlash">\\\\</xsl:param>

	<xsl:template match='/'>
		<xsl:variable name="Item" select="/rdf:RDF/bf:Item" />
		<xsl:for-each select="$Item">
			<xsl:variable name="volume_id" select="translate(translate(substring(./@rdf:about,28),'/','='),':','+')" />
			<xsl:variable name="instance_id" select="./bf:itemOf/@rdf:resource" />
			<xsl:variable name="Instance" select="/rdf:RDF/bf:Instance[@rdf:about = $instance_id][1]" />
			<xsl:variable name="work_id" select="$Instance/bf:instanceOf/@rdf:resource" />
			<xsl:variable name="Work" select="/rdf:RDF/bf:Work[@rdf:about = $work_id][1]" />

			<xsl:variable name="output_file_path">
				<xsl:value-of select="concat(concat(concat(concat(concat($output_path,'/complete/'),substring-before($volume_id,'.')),'/'),$volume_id),'.json')" />
			</xsl:variable>

			<xsl:result-document href="{$output_file_path}" method='text' exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" encoding="UTF-8">
				<xsl:text>{</xsl:text>
					<xsl:text>"metadata":{</xsl:text>
					<xsl:text>"id":"</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
					<xsl:choose>
						<xsl:when test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'mono'">
							<xsl:text>,"type":"Book"</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'serl'">
									<xsl:text>,"type":"PublicationVolume"</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>,"type":"CreativeWork"</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>,"isAccessibleForFree":</xsl:text>
						<xsl:choose>
							<xsl:when test="./dct:accessRights/text() = 'pd'">
								<xsl:text>true</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>false</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					<xsl:call-template name="title">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
					<xsl:call-template name="contribution_agents">
						<xsl:with-param name="node" select="$Work/bf:contribution/bf:Contribution[bf:agent/bf:Agent/rdfs:label/text()]" />
					</xsl:call-template>
					<xsl:if test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date and $Instance/bf:provisionActivity/bf:ProvisionActivity/rdf:type[@rdf:resource = 'http://id.loc.gov/ontologies/bibframe/Publication'] | ./dct:created">
						<xsl:choose>
							<xsl:when test="./dct:created">
								<xsl:call-template name="date">
									<xsl:with-param name="node" select="./dct:created" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="date">
									<xsl:with-param name="node" select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf']" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:call-template name="publisher">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
					<xsl:call-template name="pub_place">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
					<xsl:call-template name="languages">
						<xsl:with-param name="langs" select='$Work/bf:language/bf:Language/@rdf:about[matches(substring(.,40),"[a-z]{3}")] | $Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource[matches(substring(.,40),"[a-z]{3}")]' />
					</xsl:call-template>
					<xsl:if test="./dct:accessRights">
						<xsl:text>,"accessRights":"</xsl:text><xsl:value-of select="./dct:accessRights/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="./htrc:contentProviderAgent/@rdf:resource">
						<xsl:text>,"sourceInstitution":{</xsl:text>
						<xsl:text>"type":"http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
						<xsl:text>,"name":"</xsl:text><xsl:value-of select="substring(./htrc:contentProviderAgent/@rdf:resource,52)" /><xsl:text>"</xsl:text>
						<xsl:text>}</xsl:text>
					</xsl:if>
					<xsl:if test="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value or starts-with($Instance/@rdf:about, 'http://www.worldcat.org')">
						<xsl:text>,"mainEntityOfPage":[</xsl:text>
						<xsl:if test="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value">
							<xsl:text>"https://catalog.hathitrust.org/Record/</xsl:text><xsl:value-of select="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value/text()" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:if test="starts-with($Instance/@rdf:about, 'http://www.worldcat.org')">
							<xsl:text>,"http://catalog.hathitrust.org/api/volumes/brief/oclc/</xsl:text><xsl:value-of select="substring($Instance/@rdf:about,30)" /><xsl:text>.json"</xsl:text>
							<xsl:text>,"http://catalog.hathitrust.org/api/volumes/full/oclc/</xsl:text><xsl:value-of select="substring($Instance/@rdf:about,30)" /><xsl:text>.json"</xsl:text>
						</xsl:if>
					</xsl:if>
					<xsl:text>]</xsl:text>
					<xsl:call-template name="create_identifiers">
						<xsl:with-param name="Instance" select="$Instance" />
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:call-template name="is_n">
						<xsl:with-param name="base_path" select="$Instance/bf:identifiedBy/bf:Issn" />
						<xsl:with-param name="is_n" select="'issn'" />
					</xsl:call-template>
					<xsl:call-template name="is_n">
						<xsl:with-param name="base_path" select="$Instance/bf:identifiedBy/bf:Isbn" />
						<xsl:with-param name="is_n" select="'isbn'" />
					</xsl:call-template>
					<xsl:call-template name="subject">
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:call-template name="genre">
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:if test="./bf:enumerationAndChronology">
						<xsl:text>,"enumerationChronology":"</xsl:text><xsl:value-of select="replace(replace(./bf:enumerationAndChronology/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="$Work/rdf:type/@rdf:resource">
						<xsl:text>,"typeOfResource":"</xsl:text><xsl:value-of select="$Work/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="./htrc:lastRightsUpdateDate">
						<xsl:text>,"lastRightsUpdateDate":"</xsl:text><xsl:value-of select="./htrc:lastRightsUpdateDate/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:call-template name="part_of">
						<xsl:with-param name="Instance" select="$Instance" />
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:text>}</xsl:text>
					<xsl:text>}</xsl:text>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="title">
		<xsl:param name="Instance" />
		<xsl:variable name="iss_title" select="$Instance/bf:title/bf:Title[not(rdf:type)]" />
		<xsl:variable name="var_titles" select="$Instance/bf:title/bf:Title[rdf:type/@rdf:resource = 'http://id.loc.gov/ontologies/bibframe/VariantTitle']" />
		<xsl:choose>
			<xsl:when test="count($iss_title) = 1">
				<xsl:text>,"title":"</xsl:text><xsl:value-of select="replace(replace($iss_title/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>,"title":"</xsl:text><xsl:value-of select="replace(replace($iss_title[1]/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count($var_titles) > 0">
				<xsl:text>,"alternateTitle":[</xsl:text>
				<xsl:for-each select="$var_titles">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
				</xsl:for-each>
				<xsl:if test="count($iss_title) > 1">
					<xsl:for-each select="$iss_title">
						<xsl:if test="position() != 1">
							<xsl:text>,"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($iss_title) > 1">
					<xsl:text>,"alternateTitle":[</xsl:text>
					<xsl:for-each select="$iss_title">
						<xsl:if test="position() != 1">
							<xsl:if test="position() > 2">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="date">
		<xsl:param name="node" />
		<xsl:variable name="date_count" select="count($node)" />
		<xsl:choose>
			<xsl:when test="$date_count = 1">
				<xsl:text>,"pubDate":</xsl:text>
				<xsl:choose>
					<xsl:when test='matches(substring($node/text(),1,4),"[12]\d{3}")'>
						<xsl:value-of select="substring($node/text(),1,4)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(substring($node/text(),1,4),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$date_count > 1">
					<xsl:text>,"pubDate":</xsl:text>
					<xsl:choose>
						<xsl:when test='matches(substring($node[1]/text(),1,4),"[12]\d{3}")'>
							<xsl:value-of select="substring($node[1]/text(),1,4)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(substring($node[1]/text(),1,4),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="contribution_agents">
		<xsl:param name="node" />
		<xsl:variable name="contributor_count" select="count($node)" />
		<xsl:choose>
			<xsl:when test="$contributor_count = 1">
				<xsl:text>,"contributor":{</xsl:text>
				<xsl:text>"name":"</xsl:text><xsl:value-of select="replace(replace($node/bf:agent/bf:Agent/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
				<xsl:if test="$node/bf:agent/bf:Agent/rdf:type/@rdf:resource">
					<xsl:text>,"type":"</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
				</xsl:if>
				<xsl:if test="starts-with($node/bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
					<xsl:text>,"id":"</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
				</xsl:if>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$contributor_count > 1">
					<xsl:text>,"contributor":[</xsl:text>
					<xsl:for-each select="$node">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>{</xsl:text>
						<xsl:text>"name":"</xsl:text><xsl:value-of select="replace(replace(./bf:agent/bf:Agent/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						<xsl:if test="./bf:agent/bf:Agent/rdf:type/@rdf:resource">
							<xsl:text>,"type":"</xsl:text><xsl:value-of select="./bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:if test="starts-with(./bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
							<xsl:text>,"id":"</xsl:text><xsl:value-of select="./bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>}</xsl:text>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="publisher">
		<xsl:param name="Instance" />
		<xsl:variable name="publication_agents" select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:agent/bf:Agent[rdfs:label/text()]" />
		<xsl:choose>
			<xsl:when test="count($publication_agents) > 1" >
				<xsl:text>,"publisher":[</xsl:text>
				<xsl:for-each select="$publication_agents">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>{</xsl:text>
					<xsl:text>"type":"http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
					<xsl:if test="starts-with(./@rdf:about, 'http://www.viaf.org')">
						<xsl:text>,"id":"</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text>,"name":"</xsl:text><xsl:value-of select='replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)' /><xsl:text>"</xsl:text>
					<xsl:text>}</xsl:text>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($publication_agents) = 1" >
					<xsl:text>,"publisher":{</xsl:text>
					<xsl:text>"type":"http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
					<xsl:if test="starts-with($publication_agents/@rdf:about, 'http://www.viaf.org')">
						<xsl:text>,"id":"</xsl:text><xsl:value-of select="$publication_agents/bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text>,"name":"</xsl:text><xsl:value-of select='replace(replace($publication_agents/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)' /><xsl:text>"</xsl:text>
					<xsl:text>}</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="pub_place">
		<xsl:param name="Instance" />
		<xsl:variable name="pub_places" select='$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about[matches(substring(.,40),"[a-z]{2,3}")]' />
		<xsl:choose>
			<xsl:when test="count($pub_places) > 1" >
				<xsl:text>,"pubPlace":[</xsl:text>
				<xsl:for-each select="$pub_places">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>{</xsl:text>
					<xsl:text>"id":"</xsl:text><xsl:value-of select="." /><xsl:text>"</xsl:text>
					<xsl:text>,"type":"http://id.loc.gov/ontologies/bibframe/Place"</xsl:text>
					<xsl:text>}</xsl:text>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($pub_places) = 1">
					<xsl:text>,"pubPlace":{</xsl:text>
					<xsl:text>"id":"</xsl:text><xsl:value-of select="$pub_places" /><xsl:text>"</xsl:text>
					<xsl:text>,"type":"http://id.loc.gov/ontologies/bibframe/Place"</xsl:text>
					<xsl:text>}</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="languages">
		<xsl:param name="langs" />
		<xsl:variable name="lang_count" select="count($langs)" />
		<xsl:choose>
			<xsl:when test="$lang_count > 1">
				<xsl:variable name="lang_set" select="$langs[generate-id() = generate-id(key('lang_combined',.)[1])]" />
				<xsl:variable name="lang_set_count" select="count($lang_set)" />
				<xsl:choose>
					<xsl:when test="$lang_set_count > 1">
						<xsl:text>,"language":[</xsl:text>
						<xsl:for-each select="$lang_set">
							<xsl:if test="position() != 1">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(substring(.,40),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:for-each>
						<xsl:text>]</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$lang_set_count = 1">
								<xsl:text>,"language":"</xsl:text><xsl:value-of select="replace(replace(substring($lang_set,40),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,"language":[</xsl:text>
								<!--Create a set of unique language values present in the language structures, both with and without the identifiedBy structure-->
								<xsl:for-each select="$langs">
									<xsl:if test="position() != 1">
										<xsl:text>,</xsl:text>
									</xsl:if>
									<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(substring(.,40),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
								</xsl:for-each>
							<xsl:text>]</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$lang_count = 1">
					<xsl:text>,"language":"</xsl:text><xsl:value-of select="replace(replace(substring($langs,40),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="create_identifiers">
		<xsl:param name="Instance" />
		<xsl:param name="Work" />
		<xsl:variable name="lcc" select="$Work/bf:classification/bf:ClassificationLcc" />
		<xsl:variable name="lccn" select="$Instance/bf:identifiedBy/bf:Lccn/rdf:value" />
		<xsl:variable name="oclc" select="$Instance/bf:identifiedBy/bf:Local[bf:source/bf:Source/rdfs:label = 'OCoLC']" />
		<xsl:variable name="lcc_count" select="count($lcc)" />
		<xsl:variable name="lccn_count" select="count($lccn)" />
		<xsl:variable name="oclc_count" select="count($oclc)" />
		<xsl:variable name="identifier_count" select="$lcc_count + $lccn_count + $oclc_count" />
		<xsl:choose>
			<xsl:when test="$identifier_count = 1">
				<xsl:text>,"identifier":{</xsl:text>
				<xsl:text>"type":"PropertyValue"</xsl:text>
				<xsl:choose>
					<xsl:when test="$lcc_count = 1">
						<xsl:text>,"propertyID":"lcc"</xsl:text>
						<xsl:choose>
							<xsl:when test="count($lcc/bf:classificationPortion) > 1">
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace($lcc/bf:classificationPortion[1]/text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace($lcc/bf:classificationPortion/text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="$lcc/bf:itemPortion/text()">
							<xsl:text></xsl:text>
							<xsl:value-of select="replace(replace(.,$oneSlash,$twoSlash),$pPat,$pRep)" />
						</xsl:for-each><xsl:text>"</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$lccn_count = 1">
								<xsl:text>,"propertyID":"lccn"</xsl:text>
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace($lccn/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,"propertyID":"oclc"</xsl:text>
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace($oclc/rdf:value/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$identifier_count > 1">
					<xsl:text>,"identifier":[</xsl:text>
					<xsl:for-each select="$lcc">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>{</xsl:text>
						<xsl:text>"type":"PropertyValue"</xsl:text>
						<xsl:text>,"propertyID":"lcc"</xsl:text>
						<xsl:choose>
							<xsl:when test="count(./bf:classificationPortion) > 1">
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace(./bf:classificationPortion[1]/text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace(./bf:classificationPortion/text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:for-each select="./bf:itemPortion/text()">
							<xsl:text></xsl:text>
							<xsl:value-of select="replace(replace(.,$oneSlash,$twoSlash),$pPat,$pRep)" />
						</xsl:for-each>
						<xsl:text>"</xsl:text>
						<xsl:text>}</xsl:text>
					</xsl:for-each>
					<xsl:for-each select="$lccn">
						<xsl:if test="position() != 1 or $lcc_count > 0">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>{</xsl:text>
						<xsl:text>"type":"PropertyValue"</xsl:text>
						<xsl:text>,"propertyID":"lccn"</xsl:text>
						<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace(./text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						<xsl:text>}</xsl:text>
					</xsl:for-each>
					<xsl:for-each select="$oclc">
						<xsl:if test="position() != 1 or $lcc_count + $lccn_count > 0">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>{</xsl:text>
						<xsl:text>"type":"PropertyValue"</xsl:text>
						<xsl:text>,"propertyID":"oclc"</xsl:text>
						<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace(./rdf:value/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						<xsl:text>}</xsl:text>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$lcc_count > 0">
			<xsl:choose>
				<xsl:when test="count($lcc/bf:classificationPortion) = 1">
					<xsl:text>,"category":"</xsl:text>
					<xsl:call-template name="lcc_map">
						<xsl:with-param name="lcc_value" select="replace(replace($lcc/bf:classificationPortion/text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
					</xsl:call-template>
					<xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>,"category":[</xsl:text>
						<xsl:for-each select="$lcc/bf:classificationPortion">
							<xsl:if test="position() != 1">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text>"</xsl:text>
							<xsl:call-template name="lcc_map">
								<xsl:with-param name="lcc_value" select="replace(replace(./text(),$oneSlash,$twoSlash),$pPat,$pRep)" />
							</xsl:call-template>
							<xsl:text>"</xsl:text>
						</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="is_n">
		<xsl:param name="base_path" />
		<xsl:param name="is_n" />
		<xsl:if test="$base_path/rdf:value">
			<xsl:choose>
				<xsl:when test="count($base_path[count(./bf:status) = 0 or ./bf:status/bf:Status/rdf:label/text() != 'invalid' or ./bf:status/bf:Status/rdf:label/text() != 'incorrect']) > 1">
					<xsl:text>,"</xsl:text><xsl:value-of select="$is_n" /><xsl:text>":[</xsl:text>
					<xsl:for-each select="$base_path[count(./bf:status) = 0 or ./bf:status/bf:Status/rdf:label/text() != 'invalid' or ./bf:status/bf:Status/rdf:label/text() != 'incorrect']">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>"</xsl:text><xsl:value-of select="replace(replace(tokenize(./rdf:value/text(),' ')[position() = 1],$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="count($base_path/bf:status) = 0 or $base_path/bf:status/bf:Status/rdf:label/text() != 'invalid' or $base_path/bf:status/bf:Status/rdf:label/text() != 'incorrect'">
						<xsl:text>,"</xsl:text><xsl:value-of select="$is_n" /><xsl:text>":"</xsl:text><xsl:value-of select="replace(replace(tokenize($base_path/rdf:value/text(),' ')[position() = 1],$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="subject">
		<xsl:param name="Work" />
		<xsl:variable name="subjects" select="$Work/bf:subject/*[not(bf:Temporal)]"/>
		<xsl:if test="count($subjects) > 0">
			<xsl:text>,"subjects":[</xsl:text>
				<xsl:for-each select="$subjects">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
						<xsl:text>{</xsl:text>
						<xsl:text>"type":"</xsl:text><xsl:value-of select="./rdf:type[1]/@rdf:resource" /><xsl:text>"</xsl:text>
						<xsl:if test="starts-with(./@rdf:about, 'http://id.loc.gov')">
							<xsl:text>,"id":"</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>,"value":"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label,$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						<xsl:text>}</xsl:text>
				</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="genre">
		<xsl:param name="Work" />
		<xsl:variable name="genres" select="$Work/bf:genreForm/bf:GenreForm/@rdf:about[substring(.,1,1) != '_']" />
		<xsl:choose>
			<xsl:when test="count($genres) > 1">
				<xsl:text>,"genre":[</xsl:text>
				<xsl:for-each select="$genres">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>"</xsl:text><xsl:value-of select="." /><xsl:text>"</xsl:text>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($genres) = 1">
					<xsl:text>,"genre":"</xsl:text><xsl:value-of select="$genres" /><xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="part_of">
		<xsl:param name="Instance" />
		<xsl:param name="Work" />
		<xsl:if test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'serl'">
			<xsl:text>,"isPartOf":{</xsl:text>
			<xsl:text>"id":"</xsl:text><xsl:value-of select="$Instance/@rdf:about" /><xsl:text>"</xsl:text>
			<xsl:text>,"type":"CreativeWorkSeries"</xsl:text>
			<xsl:text>,"journalTitle":"</xsl:text><xsl:value-of select="replace(replace($Work/bf:title[1]/bf:Title/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			<xsl:text>}</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="lcc_map">
		<xsl:param name="lcc_value" />
		<xsl:choose>
			<xsl:when test="substring($lcc_value,1,1) = 'A'">
				<xsl:call-template name="lcc_map_a">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'B'">
				<xsl:call-template name="lcc_map_b">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'C'">
				<xsl:call-template name="lcc_map_c">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'D'">
				<xsl:call-template name="lcc_map_d">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'E'">
				<xsl:call-template name="lcc_map_e">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'F'">
				<xsl:call-template name="lcc_map_f">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'G'">
				<xsl:call-template name="lcc_map_g">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'H'">
				<xsl:call-template name="lcc_map_h">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'J'">
				<xsl:call-template name="lcc_map_j">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'K'">
				<xsl:call-template name="lcc_map_k">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'L'">
				<xsl:call-template name="lcc_map_l">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'M'">
				<xsl:call-template name="lcc_map_m">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'N'">
				<xsl:call-template name="lcc_map_n">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'P'">
				<xsl:call-template name="lcc_map_p">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'Q'">
				<xsl:call-template name="lcc_map_q">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'R'">
				<xsl:call-template name="lcc_map_r">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'S'">
				<xsl:call-template name="lcc_map_s">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'T'">
				<xsl:call-template name="lcc_map_t">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'U'">
				<xsl:call-template name="lcc_map_u">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'V'">
				<xsl:call-template name="lcc_map_v">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="substring($lcc_value,1,1) = 'Z'">
				<xsl:call-template name="lcc_map_z">
					<xsl:with-param name="val" select="$lcc_value" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_a">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'AC'"><xsl:text>Collections. Series. Collected works</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AE'"><xsl:text>Encyclopedias</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AG'"><xsl:text>Dictionaries and other general reference works</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AI'"><xsl:text>Indexes</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AM'"><xsl:text>Museums. Collectors and collecting</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AN'"><xsl:text>Newspapers</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AP'"><xsl:text>Periodicals</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AS'"><xsl:text>Academies and learned societies</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AY'"><xsl:text>Yearbooks. Almanacs. Directories</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'AZ'"><xsl:text>History of scholarship and learning. The humanities</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>GENERAL WORKS</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_b">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'BC'"><xsl:text>Logic</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BD'"><xsl:text>Speculative philosophy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BF'"><xsl:text>Psychology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BH'"><xsl:text>Aesthetics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BJ'"><xsl:text>Ethics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BL'"><xsl:text>Religions. Mythology. Rationalism</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BM'"><xsl:text>Judaism</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BP'"><xsl:text>Islam. Bahaism. Theosophy, etc.</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BQ'"><xsl:text>Buddhism</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BR'"><xsl:text>Christianity</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BS'"><xsl:text>The Bible</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BT'"><xsl:text>Doctrinal Theology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BV'"><xsl:text>Practical Theology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'BX'"><xsl:text>Christian Denominations</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Philosophy (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_c">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'CB'"><xsl:text>History of Civilization</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CC'"><xsl:text>Archaeology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CD'"><xsl:text>Diplomatics. Archives. Seals</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CE'"><xsl:text>Technical Chronology. Calendar</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CJ'"><xsl:text>Numismatics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CN'"><xsl:text>Inscriptions. Epigraphy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CR'"><xsl:text>Heraldry</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CS'"><xsl:text>Genealogy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'CT'"><xsl:text>Biography</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Auxiliary Sciences of History (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_d">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,3) = 'DAW'"><xsl:text>Central Europe</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DA'"><xsl:text>Great Britain</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DB'"><xsl:text>Austria - Liechtenstein - Hungary - Czechoslovakia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DC'"><xsl:text>France - Andorra - Monaco</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DD'"><xsl:text>Germany</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DE'"><xsl:text>Greco-Roman World</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DF'"><xsl:text>Greece</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DG'"><xsl:text>Italy - Malta</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DH'"><xsl:text>Low Countries - Benelux Countries</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,3) = 'DJK'"><xsl:text>Eastern Europe (General)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DJ'"><xsl:text>Netherlands (Holland)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DK'"><xsl:text>Russia. Soviet Union. Former Soviet Republics - Poland</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DL'"><xsl:text>Northern Europe. Scandinavia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DP'"><xsl:text>Spain - Portugal</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DQ'"><xsl:text>Switzerland</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DR'"><xsl:text>Balkan Peninsula</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DS'"><xsl:text>Asia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DT'"><xsl:text>Africa</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DU'"><xsl:text>Oceania (South Seas)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'DX'"><xsl:text>Romanies</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>History (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_e">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="number(substring-after($val,'E')) &lt;= 143">America</xsl:when>
			<xsl:when test="number(substring-after($val,'E')) &lt;= 909">United States</xsl:when>
			<xsl:otherwise><xsl:text>HISTORY OF THE AMERICAS</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_f">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="number(substring-after($val,'F')) &lt;= 975">United States local history</xsl:when>
			<xsl:when test="number(substring-after($val,'F')) &lt;= 1145.2">British America (including Canada)</xsl:when>
			<xsl:when test="number(substring-after($val,'F')) = 1170">French America</xsl:when>
			<xsl:when test="number(substring-after($val,'F')) &lt;= 3799">Latin America. Spanish America</xsl:when>
			<xsl:otherwise><xsl:text>HISTORY OF THE AMERICAS</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_g">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'GA'"><xsl:text>Mathematical geography. Cartography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GB'"><xsl:text>Physical geography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GC'"><xsl:text>Oceanography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GE'"><xsl:text>Environmental Sciences</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GF'"><xsl:text>Human ecology. Anthropogeography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GN'"><xsl:text>Anthropology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GR'"><xsl:text>Folklore</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GT'"><xsl:text>Manners and customs (General)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'GV'"><xsl:text>Recreation. Leisure</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Geography (General). Atlases. Maps</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_h">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'HA'"><xsl:text>Statistics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HB'"><xsl:text>Economic theory. Demography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HC'"><xsl:text>Economic history and conditions</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HD'"><xsl:text>Industries. Land use. Labor</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HE'"><xsl:text>Transportation and communications</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HF'"><xsl:text>Commerce</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HG'"><xsl:text>Finance</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HJ'"><xsl:text>Public finance</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HM'"><xsl:text>Sociology (General)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HN'"><xsl:text>Social history and conditions. Social problems. Social reform</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HQ'"><xsl:text>The family. Marriage. Women</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HS'"><xsl:text>Societies:secret, benevolent, etc.</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HT'"><xsl:text>Communities. Classes. Races</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HV'"><xsl:text>Social pathology. Social and public welfare. Criminology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'HX'"><xsl:text>Socialism. Communism. Anarchism</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Social sciences (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_j">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'JA'"><xsl:text>Political science (General)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JC'"><xsl:text>Political theory</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JF'"><xsl:text>Political institutions and public administration</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JJ'"><xsl:text>Political institutions and public administration (North America)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JK'"><xsl:text>Political institutions and public administration (United States)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JL'"><xsl:text>Political institutions and public administration (Canada, Latin America, etc.)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JN'"><xsl:text>Political institutions and public administration (Europe)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JQ'"><xsl:text>Political institutions and public administration (Asia, Africa, Australia, Pacific Area, etc.)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JS'"><xsl:text>Local government. Municipal government</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JV'"><xsl:text>Colonies and colonization. Emigration and immigration. International migration</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JX'"><xsl:text>International law, see JZ and KZ</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'JZ'"><xsl:text>International relations</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>General legislative and executive papers</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_k">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,3) = 'KBM'"><xsl:text>Jewish law</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,3) = 'KBP'"><xsl:text>Islamic law</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,3) = 'KBR'"><xsl:text>History of canon law</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,3) = 'KBU'"><xsl:text>Law of the Roman Catholic Church. The Holy See</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KB'"><xsl:text>Religious law in general. Comparative religious law. Jurisprudence</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,3) = 'KDZ'"><xsl:text>America. North America</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KD'"><xsl:text>United Kingdom and Ireland</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KE'"><xsl:text>Canada</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KF'"><xsl:text>United States</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KG'"><xsl:text>Latin America - Mexico and Central America - West Indies. Caribbean area</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KH'"><xsl:text>South America</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KJ'"><xsl:text>Europe</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KK'"><xsl:text>Europe</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KL'"><xsl:text>Asia and Eurasia, Africa, Pacific Area, and Antarctica</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KM'"><xsl:text>Asia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KN'"><xsl:text>South Asia. Southeast Asia. East Asia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KP'"><xsl:text>South Asia. Southeast Asia. East Asia</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KQ'"><xsl:text>Africa</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KR'"><xsl:text>Africa</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KS'"><xsl:text>Africa</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KT'"><xsl:text>Africa</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KU'"><xsl:text>Pacific Area</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KV'"><xsl:text>Pacific area jurisdictions</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KW'"><xsl:text>Pacific area jurisdictions</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'KZ'"><xsl:text>Law of nations</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Law in general. Comparative and uniform law. Jurisprudence</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_l">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'LA'"><xsl:text>History of education</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LB'"><xsl:text>Theory and practice of education</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LC'"><xsl:text>Special aspects of education</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LD'"><xsl:text>Individual institutions - United States</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LE'"><xsl:text>Individual institutions - America (except United States)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LF'"><xsl:text>Individual institutions - Europe</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LG'"><xsl:text>Individual institutions - Asia, Africa, Indian Ocean islands, Australia, New Zealand, Pacific islands</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LH'"><xsl:text>College and school magazines and papers</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LJ'"><xsl:text>Student fraternities and societies, United States</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'LT'"><xsl:text>Textbooks</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Education (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_m">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'ML'"><xsl:text>Literature on music</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'MT'"><xsl:text>Instruction and study</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Music</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_n">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'NA'"><xsl:text>Architecture</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'NB'"><xsl:text>Sculpture</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'NC'"><xsl:text>Drawing. Design. Illustration</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'ND'"><xsl:text>Painting</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'NE'"><xsl:text>Print media</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'NK'"><xsl:text>Decorative arts</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'NX'"><xsl:text>Arts in general</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Visual arts</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_p">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'PA'"><xsl:text>Greek language and literature. Latin language and literature</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PB'"><xsl:text>Modern languages. Celtic languages</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PC'"><xsl:text>Romance languages</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PD'"><xsl:text>Germanic languages. Scandinavian languages</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PE'"><xsl:text>English language</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PF'"><xsl:text>West Germanic languages</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PG'"><xsl:text>Slavic languages. Baltic languages. Albanian language</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PH'"><xsl:text>Uralic languages. Basque language</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PJ'"><xsl:text>Oriental languages and literatures</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PK'"><xsl:text>Indo-Iranian languages and literatures</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PL'"><xsl:text>Languages and literatures of Eastern Asia, Africa, Oceania</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PM'"><xsl:text>Hyperborean, Indian, and artificial languages</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PN'"><xsl:text>Literature (General)</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PQ'"><xsl:text>French literature - Italian literature - Spanish literature - Portuguese literature</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PR'"><xsl:text>English literature</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PS'"><xsl:text>American literature</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PT'"><xsl:text>German literature - Dutch literature - Flemish literature since 1830 - Afrikaans literature - Scandinavian literature - Old Norse literature:Old Icelandic and Old Norwegian - Modern Icelandic literature - Faroese literature - Danish literature - Norwegian literature - Swedish literature</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'PZ'"><xsl:text>Fiction and juvenile belles lettres</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Philology. Linguistics</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_q">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'QA'"><xsl:text>Mathematics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QB'"><xsl:text>Astronomy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QC'"><xsl:text>Physics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QD'"><xsl:text>Chemistry</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QE'"><xsl:text>Geology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QH'"><xsl:text>Natural history - Biology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QK'"><xsl:text>Botany</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QL'"><xsl:text>Zoology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QM'"><xsl:text>Human anatomy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QP'"><xsl:text>Physiology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'QR'"><xsl:text>Microbiology</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Science (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_r">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'RA'"><xsl:text>Public aspects of medicine</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RB'"><xsl:text>Pathology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RC'"><xsl:text>Internal medicine</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RD'"><xsl:text>Surgery</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RE'"><xsl:text>Ophthalmology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RF'"><xsl:text>Otorhinolaryngology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RG'"><xsl:text>Gynecology and obstetrics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RJ'"><xsl:text>Pediatrics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RK'"><xsl:text>Dentistry</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RL'"><xsl:text>Dermatology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RM'"><xsl:text>Therapeutics. Pharmacology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RS'"><xsl:text>Pharmacy and materia medica</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RT'"><xsl:text>Nursing</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RV'"><xsl:text>Botanic, Thomsonian, and eclectic medicine</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RX'"><xsl:text>Homeopathy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'RZ'"><xsl:text>Other systems of medicine</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Medicine (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_s">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'SB'"><xsl:text>Plant culture</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'SD'"><xsl:text>Forestry</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'SF'"><xsl:text>Animal culture</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'SH'"><xsl:text>Aquaculture. Fisheries. Angling</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'SK'"><xsl:text>Hunting sports</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Agriculture (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_t">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'TA'"><xsl:text>Engineering (General). Civil engineering</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TC'"><xsl:text>Hydraulic engineering. Ocean engineering</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TD'"><xsl:text>Environmental technology. Sanitary engineering</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TE'"><xsl:text>Highway engineering. Roads and pavements</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TF'"><xsl:text>Railroad engineering and operation</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TG'"><xsl:text>Bridge engineering</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TH'"><xsl:text>Building construction</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TJ'"><xsl:text>Mechanical engineering and machinery</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TK'"><xsl:text>Electrical engineering. Electronics. Nuclear engineering</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TL'"><xsl:text>Motor vehicles. Aeronautics. Astronautics</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TN'"><xsl:text>Mining engineering. Metallurgy</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TP'"><xsl:text>Chemical technology</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TR'"><xsl:text>Photography</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TS'"><xsl:text>Manufactures</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TT'"><xsl:text>Handicrafts. Arts and crafts</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'TX'"><xsl:text>Home economics</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Technology (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_u">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'UA'"><xsl:text>Armies:Organization, distribution, military situation</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UB'"><xsl:text>Military administration</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UC'"><xsl:text>Maintenance and transportation</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UD'"><xsl:text>Infantry</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UE'"><xsl:text>Cavalry. Armor</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UF'"><xsl:text>Artillery</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UG'"><xsl:text>Military engineering. Air forces</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'UH'"><xsl:text>Other services</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Military science (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_v">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'VA'"><xsl:text>Navies:Organization, distribution, naval situation</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VB'"><xsl:text>Naval administration</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VC'"><xsl:text>Naval maintenance</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VD'"><xsl:text>Naval seamen</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VE'"><xsl:text>Marines</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VF'"><xsl:text>Naval ordnance</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VG'"><xsl:text>Minor services of navies</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VK'"><xsl:text>Navigation. Merchant marine</xsl:text></xsl:when>
			<xsl:when test="substring($val,1,2) = 'VM'"><xsl:text>Naval architecture. Shipbuilding. Marine engineering</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Naval science (General)</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="lcc_map_z">
		<xsl:param name="val" />
		<xsl:choose>
			<xsl:when test="substring($val,1,2) = 'ZA'"><xsl:text>Information resources (General)</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>Books (General). Writing. Paleography. Book industries and trade. Libraries. Bibliography</xsl:text></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>