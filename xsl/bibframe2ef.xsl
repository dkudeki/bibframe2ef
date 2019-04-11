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

<xsl:key name="lang_combined" match="@rdf:about | @rdf:resource" use="." />
<xsl:param name="output_path" />

<!--	<xsl:ourput encoding="UTF-8" method="text" />
	<xsl:strip-space elements="*"/>-->

	<xsl:template match='/'>
		<xsl:variable name="Item" select="ext:node-set(/rdf:RDF/bf:Item)" />
		<xsl:for-each select="$Item">
			<xsl:variable name="volume_id" select="substring($Item/@rdf:about,27)" />
			<xsl:variable name="Instance" select="/rdf:RDF/bf:Instance[@rdf:about = $Item/bf:itemOf/@rdf:resource]" />
			<xsl:variable name="Work" select="/rdf:RDF/bf:Work[@rdf:about = $Instance/bf:instanceOf/@rdf:resource]" />
			<!--		<xsl:variable name="saveAs" select="ef_example.jsonld"/>-->

			<xsl:variable name="output_file_path">
				<xsl:choose>
					<xsl:when test="not($output_path)">
						<xsl:value-of select="concat(concat('./outputs/',$volume_id),'.json')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(concat(concat(concat('file:///',$output_path),'/'),$volume_id),'.json')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:result-document href="{$output_file_path}" method='text' exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" encoding="UTF-8">
				<xsl:text>{</xsl:text>
	<!--				<xsl:text>{ &#10;	"@context": [</xsl:text>
					<xsl:text> &#10;		"http://schema.org"</xsl:text>
					<xsl:text>, &#10;		{</xsl:text>
					<xsl:text> &#10;			"htrc": "http://wcsa.htrc.illinois.edu/"</xsl:text>
					<xsl:text>, &#10;			"accessProfile": {</xsl:text>
					<xsl:text> &#10;				"@id": "htrc:accessProfile"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
					<xsl:text>, &#10;			"title": "name"</xsl:text>
					<xsl:text>, &#10;			"enumerationChronology": {</xsl:text>
					<xsl:text> &#10;				"@id": "htrc:enumerationChronology"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
					<xsl:text>, &#10;			"pubDate": "datePublished"</xsl:text>
					<xsl:text>, &#10;			"pubPlace": "locationCreated"</xsl:text>
					<xsl:text>, &#10;			"language": "inLanguage"</xsl:text>
					<xsl:text>, &#10;			"rightsAttributes": {</xsl:text>
					<xsl:text> &#10;				"@id": "htrc:accessRights"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
					<xsl:text>, &#10;			"contributor": {</xsl:text>
					<xsl:text> &#10;				"@id": "schema:contributor"</xsl:text>
					<xsl:text>, &#10;				"@container": "@list"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
					<xsl:text>, &#10;			"sourceInstitution": "provider"</xsl:text>
					<xsl:text>, &#10;			"lastUpdateDate": "dateModified"</xsl:text>
					<xsl:text>, &#10;			"identifier": {</xsl:text>
					<xsl:text> &#10;				"@id": "schema:identifier"</xsl:text>
					<xsl:text>, &#10;				"@container": "@list"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
					<xsl:text> &#10;		}</xsl:text>
					<xsl:text> &#10;	]</xsl:text>
					<xsl:text>, &#10;	"type": "Dataset"</xsl:text>
					<xsl:text>, &#10;	"schemaVersion": "https://wiki.htrc.illinois.edu/display/COM/Extracted+Features+Dataset_2.0"</xsl:text>
					<xsl:text>, &#10;	"sourceInstitution": "htrc"</xsl:text>-->
					<xsl:text> &#10;	"metadata": {</xsl:text>
					<xsl:text> &#10;		"id": "</xsl:text><xsl:value-of select="$Item/@rdf:about" /><xsl:text>"</xsl:text>
					<xsl:choose>
						<xsl:when test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'mono'">
							<xsl:text>, &#10;		"type": "Book"</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'serl'">
									<xsl:text>, &#10;		"type": "PublicationVolume"</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>, &#10;		"type": "CreativeWork"</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
	<!--				<xsl:text>, &#10;		"type": "</xsl:text><xsl:value-of select="substring(/rdf:RDF/bf:Instance/bf:issuance/bf:Issuance/@rdf:about,39)" /><xsl:text>"</xsl:text>-->
					<xsl:text>, &#10;		"isAccessibleForFree": </xsl:text>
						<xsl:choose>
							<xsl:when test="$Item/dct:accessRights/text() = 'pd'">
								<xsl:text>true</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>false</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
	<!--				<xsl:text>, &#10;		"title": "</xsl:text><xsl:value-of select="$Instance/bf:title/bf:Title/rdfs:label/text()" /><xsl:text>"</xsl:text>-->
					<xsl:call-template name="title">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
					<xsl:call-template name="contribution_agents">
						<xsl:with-param name="node" select="$Work/bf:contribution/bf:Contribution" />
					</xsl:call-template>
					<xsl:if test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date">
						<xsl:text>, &#10;		"pubDate": </xsl:text><xsl:value-of select="substring($Item/dct:created/text(),1,4)" />
					</xsl:if>
					<xsl:call-template name="publisher">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
	<!--				<xsl:if test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:agent/bf:Agent/rdfs:label">
						<xsl:text>, &#10;		"publisher": {</xsl:text>
						<xsl:text> &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
						<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:agent/bf:Agent/rdfs:label/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:if>-->
					<xsl:call-template name="pub_place">
						<xsl:with-param name="Instance" select="$Instance" />
					</xsl:call-template>
	<!--				<xsl:choose>
						<xsl:when test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about and $Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/rdfs:label">
							<xsl:text>, &#10;		"pubPlace": [</xsl:text>
							<xsl:text> &#10;			"</xsl:text><xsl:value-of select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about" /><xsl:text>"</xsl:text>
							<xsl:text>, &#10;			"</xsl:text><xsl:value-of select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/rdfs:label/text()" /><xsl:text>"</xsl:text>
							<xsl:text> &#10;		]</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about">
									<xsl:text>, &#10;		"pubPlace": "</xsl:text><xsl:value-of select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about" /><xsl:text>"</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:if test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/rdfs:label">
										<xsl:text>, &#10;		"pubPlace": "</xsl:text><xsl:value-of select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/rdfs:label/text()" /><xsl:text>"</xsl:text>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>-->
					<xsl:call-template name="languages">
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
	<!--				<xsl:choose>
						<xsl:when test="$Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource">
							<xsl:choose>
								<xsl:when test="count($Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource) > 1">
									<xsl:text>, &#10;		"inLanguage": [</xsl:text>
									<xsl:for-each select="$Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource">
										<xsl:text> &#10;			"</xsl:text><xsl:value-of select="substring(.,40)" /><xsl:text>"</xsl:text>
										<xsl:if test="position() != last()">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
									<xsl:text> &#10;		]</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>, &#10;		"inLanguage": "</xsl:text><xsl:value-of select="substring($Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource,40)" /><xsl:text>"</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$Work/bf:language/bf:Language/@rdf:about">
								<xsl:text>, &#10;		"inLanguage": "</xsl:text><xsl:value-of select="substring($Work/bf:language/bf:Language/@rdf:about,40)" /><xsl:text>"</xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>-->
					<xsl:if test="$Item/dct:accessRights">
						<xsl:text>, &#10;		"accessRights": "</xsl:text><xsl:value-of select="$Item/dct:accessRights/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="$Item/htrc:contentProviderAgent/@rdf:resource">
						<xsl:text>, &#10;		"sourceInstitution": {</xsl:text>
						<xsl:text> &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
						<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="substring($Item/htrc:contentProviderAgent/@rdf:resource,52)" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:if>
					<xsl:text>, &#10;		"mainEntityOfPage": [</xsl:text>
					<xsl:text> &#10;			"http://catalog.hathitrust.org/api/volumes/brief/oclc/</xsl:text><xsl:value-of select="substring($Item/bf:itemOf/@rdf:resource,30)" /><xsl:text>.json"</xsl:text>
					<xsl:text>, &#10;			"http://catalog.hathitrust.org/api/volumes/full/oclc/</xsl:text><xsl:value-of select="substring($Item/bf:itemOf/@rdf:resource,30)" /><xsl:text>.json"</xsl:text>
					<xsl:text>, &#10;			"https://catalog.hathitrust.org/Record/</xsl:text><xsl:value-of select="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value/text()" /><xsl:text>"</xsl:text>
					<xsl:text> &#10;		]</xsl:text>
					<xsl:call-template name="create_identifiers">
						<xsl:with-param name="Instance" select="$Instance" />
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:if test="$Instance/bf:identifiedBy/bf:Issn/rdf:value">
						<xsl:text>, &#10;		"issn": "</xsl:text><xsl:value-of select="$Instance/bf:identifiedBy/bf:Issn/rdf:value/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="$Instance/bf:identifiedBy/bf:Isbn/rdf:value">
						<xsl:text>, &#10;		"issn": "</xsl:text><xsl:value-of select="$Instance/bf:identifiedBy/bf:Isbn/rdf:value/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:call-template name="subject">
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
	<!--				<xsl:if test="$Work/bf:genreForm/bf:GenreForm/@rdf:about">
						<xsl:variable name="genre_count" select="count($Work/bf:genreForm/bf:GenreForm/@rdf:about)" />
						<xsl:choose>
							<xsl:when test="$genre_count = 1">
								<xsl:text>, &#10;		"genre": "</xsl:text><xsl:value-of select="$Work/bf:genreForm/bf:GenreForm/@rdf:about" /><xsl:text>"</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$genre_count > 1">
									<xsl:text>, &#10;		"genre": [</xsl:text>
									<xsl:for-each select="$Work/bf:genreForm/bf:GenreForm/@rdf:about">
										<xsl:if test="position() != 1">
											<xsl:text>,</xsl:text>
										</xsl:if>
										<xsl:text> &#10;			"</xsl:text><xsl:value-of select="." /><xsl:text>"</xsl:text>
									</xsl:for-each>
									<xsl:text> &#10;		]</xsl:text>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>-->
					<xsl:call-template name="genre">
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:if test="$Item/bf:enumerationAndChronology">
						<xsl:text>, &#10;		"enumerationChronology": "</xsl:text><xsl:value-of select="$Item/bf:enumerationAndChronology/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="$Work/rdf:type/@rdf:resource">
						<xsl:text>, &#10;		"typeOfResource": "</xsl:text><xsl:value-of select="$Work/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:call-template name="part_of">
						<xsl:with-param name="Instance" select="$Instance" />
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
	<!--				<xsl:if test="$Instance/bf:genreForm/bf:GenreForm/rdfs:label and $Instance/bf:genreForm/bf:GenreForm/rdfs:label/text() = 'periodical'">
						<xsl:if test="matches($Item/bf:enumerationAndChronology/text(),'no.')">
							<xsl:text>, &#10;		"issueNumber": "</xsl:text>
							<xsl:choose>
								<xsl:when test="matches($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')">
									<xsl:text>no.</xsl:text><xsl:value-of select="tokenize(tokenize($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')[1],'no.')[2]" /><xsl:text>-</xsl:text><xsl:text>no.</xsl:text><xsl:value-of select="tokenize(tokenize($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')[last()],'no.')[2]" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>no.</xsl:text><xsl:value-of select="tokenize($Item/bf:enumerationAndChronology/text(),'no.')[2]" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>, &#10;		"isPartOf": {</xsl:text>
						<xsl:text> &#10;			"title": "</xsl:text><xsl:value-of select="$Work/bf:title/bf:Title/rdfs:label/text()" /><xsl:text>"</xsl:text>
						<xsl:if test="$Item/bf:enumerationAndChronology">
							<xsl:text> &#10;			"enumerationChronology": "</xsl:text>
							<xsl:choose>
								<xsl:when test="matches($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')">
									<xsl:value-of select="normalize-space(tokenize(tokenize($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')[1],'no.')[1])" /><xsl:text>-</xsl:text><xsl:text>v.</xsl:text><xsl:value-of select="normalize-space(tokenize(tokenize($Item/bf:enumerationAndChronology/text(),'-[: ]?v.')[last()],'no.')[1])" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="tokenize($Item/bf:enumerationAndChronology/text(),'no.')[1]" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:text>, &#10;			"isPartOf": {</xsl:text>
						<xsl:text> &#10;				"id": "</xsl:text><xsl:value-of select="$Instance/@rdf:about" /><xsl:text>"</xsl:text>
						<xsl:text>, &#10;				"title": "</xsl:text><xsl:value-of select="$Work/bf:title/bf:Title/rdfs:label/text()" /><xsl:text>"</xsl:text>
						<xsl:text>, &#10;				"type": "Periodical"</xsl:text>
						<xsl:if test="$Instance/bf:identifiedBy/bf:Issn/rdf:value">
							<xsl:text>, &#10;				"issn": "</xsl:text><xsl:value-of select="$Instance/bf:identifiedBy/bf:Issn/rdf:value/text()" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			}</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:if>
					<xsl:text> &#10;	}</xsl:text>-->
					<xsl:text>&#10;}</xsl:text>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="title">
		<xsl:param name="Instance" />
		<xsl:variable name="iss_title" select="$Instance/bf:title/bf:Title[not(rdf:type)]" />
		<xsl:variable name="var_titles" select="$Instance/bf:title/bf:Title[rdf:type/@rdf:resource = 'http://id.loc.gov/ontologies/bibframe/VariantTitle']" />
		<xsl:text>, &#10;		"title": "</xsl:text><xsl:value-of select="$iss_title/rdfs:label/text()" /><xsl:text>"</xsl:text>
		<xsl:if test="count($var_titles) > 0">
			<xsl:text>, &#10;		"alternateTitle": [</xsl:text>
			<xsl:for-each select="$var_titles">
				<xsl:if test="position() != 1">
					<xsl:text>,</xsl:text>
				</xsl:if>
				<xsl:text>&#10;			"</xsl:text><xsl:value-of select="./rdfs:label/text()" /><xsl:text>"</xsl:text>
			</xsl:for-each>
			<xsl:text>&#10;		]</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="contribution_agents"><!-- match="$Work/bf:contribution/bf:Contribution/">-->
		<xsl:param name="node" />
		<xsl:variable name="contributor_count" select="count($node)" />
		<xsl:choose>
			<xsl:when test="$contributor_count = 1">
				<xsl:text>, &#10;		"contributor": {</xsl:text>
				<xsl:text> &#10;			"type": "</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
				<xsl:if test="starts-with($node/bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
					<xsl:text>, &#10;			"id": "</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
				</xsl:if>
				<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/rdfs:label/text()" /><xsl:text>"</xsl:text>
				<xsl:text> &#10;		}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$contributor_count > 1">
					<xsl:text>, &#10;		"contributor": [</xsl:text>
					<xsl:for-each select="$node">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			{</xsl:text>
						<xsl:text> &#10;				"type": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
						<xsl:if test="starts-with(bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
							<xsl:text>, &#10;				"id": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>, &#10;				"name": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/rdfs:label/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;			}</xsl:text>
					</xsl:for-each>
					<xsl:text> &#10;		]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
<!--		<xsl:for-each select="$node">
			<xsl:text>, &#10;		"contributor": {</xsl:text>
			<xsl:text> &#10;			"type": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
			<xsl:text> &#10;			"id": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
			<xsl:text> &#10;			"name": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/rdfs:label/text()" /><xsl:text>"</xsl:text>
			<xsl:text> &#10;		}</xsl:text>
			</xsl:for-each>-->
	</xsl:template>

	<xsl:template name="publisher">
		<xsl:param name="Instance" />
		<xsl:variable name="publishers" select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:agent/bf:Agent/rdfs:label" />
		<xsl:choose>
			<xsl:when test="count($publishers) > 1" >
				<xsl:text>, &#10;		"publisher": [</xsl:text>
				<xsl:for-each select="$publishers">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text> &#10;			{</xsl:text>
					<xsl:text> &#10;				"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
					<xsl:text>, &#10;				"name": "</xsl:text><xsl:value-of select="./text()" /><xsl:text>"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
				</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($publishers) = 1" >
					<xsl:text>, &#10;		"publisher": {</xsl:text>
					<xsl:text> &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
					<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="$publishers/text()" /><xsl:text>"</xsl:text>
					<xsl:text> &#10;		}</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="pub_place">
		<xsl:param name="Instance" />
		<xsl:variable name="pub_places" select="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:place/bf:Place/@rdf:about" />
		<xsl:choose>
			<xsl:when test="count($pub_places) > 1" >
				<xsl:text>, &#10;		"pubPlace": [</xsl:text>
				<xsl:for-each select="$pub_places">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text> &#10;			{</xsl:text>
					<xsl:text> &#10;				"id": "</xsl:text><xsl:value-of select="." /><xsl:text>"</xsl:text>
					<xsl:text>, &#10;				"type": "http://id.loc.gov/ontologies/bibframe/Place"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
				</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($pub_places) = 1">
					<xsl:text>, &#10;		"pubPlace": {</xsl:text>
					<xsl:text> &#10;			"id": "</xsl:text><xsl:value-of select="$pub_places" /><xsl:text>"</xsl:text>
					<xsl:text>, &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Place"</xsl:text>
					<xsl:text> &#10;		}</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="languages">
		<xsl:param name="Work" />
		<xsl:variable name="lang_strs" select="$Work/bf:language/bf:Language/@rdf:about" />
		<xsl:variable name="lang_nodes" select="$Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource" />
		<xsl:variable name="lang_strs_count" select="count($lang_strs)" />
		<xsl:variable name="lang_nodes_count" select="count($lang_nodes)" />
		<xsl:variable name="lang_count" select="$lang_strs_count + $lang_nodes_count" />
		<xsl:choose>
			<xsl:when test="$lang_count > 1">
				<xsl:text>, &#10;		"inLanguage": [</xsl:text>
					<xsl:for-each select="$Work/bf:language/bf:Language/@rdf:about[generate-id() = generate-id(key('lang_combined',.)[1])] | $Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource[generate-id() = generate-id(key('lang_combined',.)[1])]">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			"</xsl:text><xsl:value-of select="substring(.,40)" /><xsl:text>"</xsl:text>
					</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
<!--				<xsl:variable name="lang_combined" select="$Work/bf:language/bf:Language/@rdf:about | $Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource" />-->
<!--				<xsl:for-each select="$lang_combined">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text> &#10;			"</xsl:text><xsl:value-of select="substring(.,40)" /><xsl:text>"</xsl:text>
				</xsl:for-each>-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$lang_count = 1">
					<xsl:text>, &#10;		"inLanguage": "</xsl:text>
					<xsl:choose>
						<xsl:when test="$lang_strs_count = 1">
							<xsl:value-of select="substring($lang_strs,40)" /><xsl:text>"</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring($lang_nodes,40)" /><xsl:text>"</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
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
				<xsl:text>, &#10;		"identifier": {</xsl:text>
				<xsl:text> &#10;			"type": "PropertyValue"</xsl:text>
				<xsl:choose>
					<xsl:when test="$lcc_count = 1">
						<xsl:text>, &#10;			"propertyID": "lcc"</xsl:text>
						<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="$lcc/bf:classificationPortion/text()" /><xsl:text> </xsl:text><xsl:value-of select="$lcc/bf:itemPortion/text()" /><xsl:text>"</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$lccn_count = 1">
								<xsl:text>, &#10;			"propertyID": "lccn"</xsl:text>
								<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="$lccn/text()" /><xsl:text>"</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>, &#10;			"propertyID": "oclc"</xsl:text>
								<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="$oclc/rdf:value/text()" /><xsl:text>"</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> &#10;		}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$identifier_count > 1">
					<xsl:text>, &#10;		"identifier": [</xsl:text>
					<xsl:for-each select="$lcc">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			{</xsl:text>
						<xsl:text> &#10;				"type": "PropertyValue"</xsl:text>
						<xsl:text>, &#10;				"propertyID": "lcc"</xsl:text>
						<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="./bf:classificationPortion/text()" /><xsl:text> </xsl:text><xsl:value-of select="./bf:itemPortion/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;			}</xsl:text>
					</xsl:for-each>
					<xsl:for-each select="$lccn">
						<xsl:if test="position() != 1 or $lcc_count > 0">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			{</xsl:text>
						<xsl:text> &#10;				"type": "PropertyValue"</xsl:text>
						<xsl:text>, &#10;				"propertyID": "lccn"</xsl:text>
						<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="./text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;			}</xsl:text>
					</xsl:for-each>
					<xsl:for-each select="$oclc">
						<xsl:if test="position() != 1 or $lcc_count + $lccn_count > 0">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			{</xsl:text>
						<xsl:text> &#10;				"type": "PropertyValue"</xsl:text>
						<xsl:text>, &#10;				"propertyID": "oclc"</xsl:text>
						<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="./rdf:value/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;			}</xsl:text>
					</xsl:for-each>
					<xsl:text> &#10;		]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$lcc_count > 0">
			<xsl:choose>
				<xsl:when test="$lcc_count = 1">
					<xsl:text>, &#10;		"category": "</xsl:text><xsl:value-of select="$lcc/bf:classificationPortion/text()" /><xsl:text> </xsl:text><xsl:value-of select="$lcc/bf:itemPortion/text()" /><xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>, &#10;		"category": [</xsl:text>
						<xsl:for-each select="$lcc">
							<xsl:if test="position() != 1">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text> &#10;			"</xsl:text><xsl:value-of select="./bf:classificationPortion/text()" /><xsl:text> </xsl:text><xsl:value-of select="./bf:itemPortion/text()" /><xsl:text>"</xsl:text>
						</xsl:for-each>
					<xsl:text> &#10;		]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
<!--		<xsl:choose>
			<xsl:when test="$subclass = 'Lcc'">
				<xsl:if test="$Work/bf:classification/bf:ClassificationLcc">
					<xsl:for-each select="$Work/bf:classification/bf:ClassificationLcc">
						<xsl:text>, &#10;		"identifier": {</xsl:text>
						<xsl:text> &#10;			"type": "PropertyValue"</xsl:text>
						<xsl:text>, &#10;			"propertyID": "</xsl:text><xsl:value-of select="lower-case($subclass)" /><xsl:text>"</xsl:text>
						<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="./bf:classificationPortion/text()" /><xsl:text> </xsl:text><xsl:value-of select="./bf:itemPortion/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$Instance/bf:identifiedBy/*[name() = concat('bf:',$subclass)]/rdf:value">
					<xsl:for-each select="$Instance/bf:identifiedBy/*[name() = concat('bf:',$subclass)]">
						<xsl:text>, &#10;		"identifier": {</xsl:text>
						<xsl:text> &#10;			"type": "PropertyValue"</xsl:text>
						<xsl:text>, &#10;			"propertyID": "</xsl:text><xsl:value-of select="lower-case($subclass)" /><xsl:text>"</xsl:text>
						<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="./rdf:value/text()" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:for-each>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>-->
	</xsl:template>

	<xsl:template name="subject">
		<xsl:param name="Work" />
		<xsl:variable name="subjects" select="$Work/bf:subject/*[not(bf:Temporal)]"/>
		<xsl:if test="count($subjects) > 0">
			<xsl:text>, &#10;		"subjects": [</xsl:text>
				<xsl:for-each select="$subjects">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="substring(./@rdf:about,1,1) != '_'">
							<xsl:text> &#10;			{</xsl:text>
							<xsl:text> &#10;				"id": "</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
							<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="./rdfs:label" /><xsl:text>"</xsl:text>
							<xsl:text>, &#10;				"type": "</xsl:text><xsl:value-of select="./rdf:type[1]/@rdf:resource" /><xsl:text>"</xsl:text>
							<xsl:text> &#10;			}</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> &#10;			"</xsl:text><xsl:value-of select="./rdfs:label" /><xsl:text>"</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			<xsl:text> &#10;		]</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="genre">
		<xsl:param name="Work" />
		<xsl:variable name="genres" select="$Work/bf:genreForm/bf:GenreForm/@rdf:about[substring(.,1,1) != '_']" />
		<xsl:choose>
			<xsl:when test="count($genres) > 1">
				<xsl:text>, &#10;		"genre": [</xsl:text>
				<xsl:for-each select="$genres">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text> &#10;			"</xsl:text><xsl:value-of select="." /><xsl:text>"</xsl:text>
				</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($genres) = 1">
					<xsl:text>, &#10;		"genre": "</xsl:text><xsl:value-of select="$genres" /><xsl:text>"</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="part_of">
		<xsl:param name="Instance" />
		<xsl:param name="Work" />
		<xsl:if test="substring($Instance/bf:issuance/bf:Issuance/@rdf:about,39) = 'serl'">
			<xsl:text>, &#10;		"isPartOf": {</xsl:text>
			<xsl:text> &#10;			"id": "</xsl:text><xsl:value-of select="$Instance/@rdf:about" /><xsl:text>"</xsl:text>
			<xsl:text>, &#10;			"type": "CreativeWorkSeries"</xsl:text>
			<xsl:text>, &#10;			"journalTitle": "</xsl:text><xsl:value-of select="$Work/bf:title/bf:Title/rdfs:label/text()" /><xsl:text>"</xsl:text>
			<xsl:text> &#10;		}</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>