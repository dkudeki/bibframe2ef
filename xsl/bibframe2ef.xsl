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
<xsl:key name="instances" match="/rdf:RDF/bf:Instance" use="@rdf:about" />
<xsl:key name="works" match="/rdf:RDF/bf:Work" use="@rdf:about" />
<xsl:param name="output_path" />
<xsl:param name="filename" />
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
				<xsl:choose>
					<xsl:when test="not($output_path)">
						<xsl:choose>
							<xsl:when test="$Instance/bf:title/bf:Title">
								<xsl:value-of select="concat(concat('./outputs/complete/',$volume_id),'.json')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(concat('./outputs/incomplete/',$volume_id),'.json')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$Instance/bf:title/bf:Title">
								<xsl:value-of select="concat(concat(concat($output_path,'/complete/'),$volume_id),'.json')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(concat(concat($output_path,'/incomplete/'),$volume_id),'.json')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:result-document href="{$output_file_path}" method='text' exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" encoding="UTF-8">
				<xsl:text>{</xsl:text>
					<xsl:text> &#10;	"metadata": {</xsl:text>
					<xsl:text> &#10;		"id": "</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
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
					<xsl:text>, &#10;		"isAccessibleForFree": </xsl:text>
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
						<xsl:with-param name="node" select="$Work/bf:contribution/bf:Contribution" />
					</xsl:call-template>
					<xsl:if test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date | ./dct:created">
						<xsl:choose>
							<xsl:when test="./dct:created">
								<xsl:text>, &#10;		"pubDate": </xsl:text>
								<xsl:choose>
									<xsl:when test='matches(substring(./dct:created/text(),1,4),"\d{4}")'>
										<xsl:value-of select="substring(./dct:created/text(),1,4)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>"</xsl:text><xsl:value-of select="substring(./dct:created/text(),1,4)" /><xsl:text>"</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>, &#10;		"pubDate": </xsl:text>
								<xsl:choose>
									<xsl:when test="$Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf']">
										<xsl:choose>
											<xsl:when test="matches(substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4),'\d{4}')">
												<xsl:value-of select="substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4)" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>"</xsl:text><xsl:value-of select="substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4)" /><xsl:text>"</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test='matches(substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4),"\d{4}")'>
												<xsl:value-of select="substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4)" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>"</xsl:text><xsl:value-of select="substring($Instance/bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4)" /><xsl:text>"</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
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
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:if test="./dct:accessRights">
						<xsl:text>, &#10;		"accessRights": "</xsl:text><xsl:value-of select="./dct:accessRights/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="./htrc:contentProviderAgent/@rdf:resource">
						<xsl:text>, &#10;		"sourceInstitution": {</xsl:text>
						<xsl:text> &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
						<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="substring(./htrc:contentProviderAgent/@rdf:resource,52)" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;		}</xsl:text>
					</xsl:if>
					<xsl:text>, &#10;		"mainEntityOfPage": [</xsl:text>
					<xsl:text> &#10;			"http://catalog.hathitrust.org/api/volumes/brief/oclc/</xsl:text><xsl:value-of select="substring($Instance/@rdf:about,30)" /><xsl:text>.json"</xsl:text>
					<xsl:text>, &#10;			"http://catalog.hathitrust.org/api/volumes/full/oclc/</xsl:text><xsl:value-of select="substring($Instance/@rdf:about,30)" /><xsl:text>.json"</xsl:text>
					<xsl:if test="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value">
						<xsl:text>, &#10;			"https://catalog.hathitrust.org/Record/</xsl:text><xsl:value-of select="$Work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text> &#10;		]</xsl:text>
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
						<xsl:text>, &#10;		"enumerationChronology": "</xsl:text><xsl:value-of select="replace(replace(./bf:enumerationAndChronology/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:if test="$Work/rdf:type/@rdf:resource">
						<xsl:text>, &#10;		"typeOfResource": "</xsl:text><xsl:value-of select="$Work/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:call-template name="part_of">
						<xsl:with-param name="Instance" select="$Instance" />
						<xsl:with-param name="Work" select="$Work" />
					</xsl:call-template>
					<xsl:text> &#10;	}</xsl:text>
					<xsl:text>&#10;}</xsl:text>
			</xsl:result-document>
		</xsl:for-each>

		<!--This section is for mapping Instance OCLC numbers to Work OCLC numbers, and Work OCLC numbers to general metadata for those works. By storing this we should be able to get around
			records that are sparse because the full Work/Instance record are not present after their first appearance-->
		<xsl:variable name="instance_file_path">
			<xsl:choose>
				<xsl:when test="not($output_path)">
					<xsl:value-of select="concat(concat('./outputs/dicts/',$filename),'_instance.json')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(concat(concat($output_path,'/dicts/'),$filename),'_instance.json')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="meta_file_path">
			<xsl:choose>
				<xsl:when test="not($output_path)">
					<xsl:value-of select="concat(concat('./outputs/dicts/',$filename),'_meta.json')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat(concat(concat($output_path,'/dicts/'),$filename),'_meta.json')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:result-document href="{$instance_file_path}" method='text' exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" encoding="UTF-8">
			<xsl:variable name="instance_set" select="/rdf:RDF/bf:Instance[generate-id() = generate-id(key('instances',./@rdf:about)[1])]" />
			<xsl:text>{</xsl:text>
				<xsl:for-each select="$instance_set">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>&#10;	"</xsl:text>
					<xsl:choose>
						<xsl:when test="substring(./@rdf:about,1,1) != '_'">
							<xsl:value-of select="substring(./@rdf:about,30)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="./@rdf:about" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>":	"</xsl:text>
					<xsl:choose>
						<xsl:when test="substring(./bf:instanceOf/@rdf:resource,1,1) != '_'">
							<xsl:value-of select="substring(./bf:instanceOf/@rdf:resource,36)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="./bf:instanceOf/@rdf:resource" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>"</xsl:text>
				</xsl:for-each>
			<xsl:text>&#10;}</xsl:text>
		</xsl:result-document>

		<xsl:result-document href="{$meta_file_path}" method='text' exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="no" encoding="UTF-8">
			<xsl:variable name="instance_set" select="/rdf:RDF/bf:Instance[generate-id() = generate-id(key('instances',./@rdf:about)[1])]" />
			<xsl:text>{</xsl:text>
				<xsl:for-each select="$instance_set[./bf:title/bf:Title]">
					<xsl:variable name="full_work_id" select="./bf:instanceOf/@rdf:resource" />
					<xsl:variable name="full_work" select="/rdf:RDF/bf:Work[@rdf:about = $full_work_id][1]" />
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>&#10;	"</xsl:text>
					<xsl:choose>
						<xsl:when test="substring(./bf:instanceOf/@rdf:resource,1,1) != '_'">
							<xsl:value-of select="substring(./bf:instanceOf/@rdf:resource,36)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="./bf:instanceOf/@rdf:resource" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>":	{</xsl:text>
					<xsl:text>&#10;		"mainEntityOfPage": [</xsl:text>
					<xsl:text> &#10;			"http://catalog.hathitrust.org/api/volumes/brief/oclc/</xsl:text><xsl:value-of select="substring(./@rdf:about,30)" /><xsl:text>.json"</xsl:text>
					<xsl:text>, &#10;			"http://catalog.hathitrust.org/api/volumes/full/oclc/</xsl:text><xsl:value-of select="substring(./@rdf:about,30)" /><xsl:text>.json"</xsl:text>
					<xsl:if test="$full_work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value">
						<xsl:text>, &#10;			"https://catalog.hathitrust.org/Record/</xsl:text><xsl:value-of select="$full_work/bf:adminMetadata/bf:AdminMetadata/bf:identifiedBy/bf:Local/rdf:value/text()" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text> &#10;		]</xsl:text>
					<xsl:call-template name="title">
						<xsl:with-param name="Instance" select="." />
					</xsl:call-template>
					<xsl:call-template name="contribution_agents">
						<xsl:with-param name="node" select="$full_work/bf:contribution/bf:Contribution" />
					</xsl:call-template>
					<xsl:if test="./bf:provisionActivity/bf:ProvisionActivity/bf:date and ./bf:provisionActivity/bf:ProvisionActivity/rdf:type[@rdf:resource = 'http://id.loc.gov/ontologies/bibframe/Publication']">
						<xsl:text>, &#10;		"pubDate": </xsl:text>
							<xsl:choose>
								<xsl:when test="./bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf']">
									<xsl:choose>
										<xsl:when test="matches(substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4),'\d{4}')">
											<xsl:value-of select="substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>"</xsl:text><xsl:value-of select="substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[@rdf:datatype = 'http://id.loc.gov/datatypes/edtf'][1]/text(),1,4)" /><xsl:text>"</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test='matches(substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4),"\d{4}")'>
											<xsl:value-of select="substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4)" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>"</xsl:text><xsl:value-of select="substring(./bf:provisionActivity/bf:ProvisionActivity/bf:date[1]/text(),1,4)" /><xsl:text>"</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
					</xsl:if>
					<xsl:call-template name="publisher">
						<xsl:with-param name="Instance" select="." />
					</xsl:call-template>
					<xsl:call-template name="pub_place">
						<xsl:with-param name="Instance" select="." />
					</xsl:call-template>
					<xsl:call-template name="languages">
						<xsl:with-param name="Work" select="$full_work" />
					</xsl:call-template>
						<xsl:call-template name="create_identifiers">
						<xsl:with-param name="Instance" select="." />
						<xsl:with-param name="Work" select="$full_work" />
					</xsl:call-template>
					<xsl:call-template name="is_n">
						<xsl:with-param name="base_path" select="./bf:identifiedBy/bf:Issn" />
						<xsl:with-param name="is_n" select="'issn'" />
					</xsl:call-template>
					<xsl:call-template name="is_n">
						<xsl:with-param name="base_path" select="./bf:identifiedBy/bf:Isbn" />
						<xsl:with-param name="is_n" select="'isbn'" />
					</xsl:call-template>
					<xsl:call-template name="subject">
						<xsl:with-param name="Work" select="$full_work" />
					</xsl:call-template>
					<xsl:call-template name="genre">
						<xsl:with-param name="Work" select="$full_work" />
					</xsl:call-template>
					<xsl:if test="$full_work/rdf:type/@rdf:resource">
						<xsl:text>, &#10;		"typeOfResource": "</xsl:text><xsl:value-of select="$full_work/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:call-template name="part_of">
						<xsl:with-param name="Instance" select="." />
						<xsl:with-param name="Work" select="$full_work" />
					</xsl:call-template>
					<xsl:text> &#10;	}</xsl:text>
				</xsl:for-each>
			<xsl:text>&#10;}</xsl:text>
		</xsl:result-document>
	</xsl:template>

	<xsl:template name="title">
		<xsl:param name="Instance" />
		<xsl:variable name="iss_title" select="$Instance/bf:title/bf:Title[not(rdf:type)]" />
		<xsl:variable name="var_titles" select="$Instance/bf:title/bf:Title[rdf:type/@rdf:resource = 'http://id.loc.gov/ontologies/bibframe/VariantTitle']" />
		<xsl:choose>
			<xsl:when test="count($iss_title) = 1">
				<xsl:text>, &#10;		"title": "</xsl:text><xsl:value-of select="replace(replace($iss_title/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>, &#10;		"title": "</xsl:text><xsl:value-of select="replace(replace($iss_title[1]/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="count($var_titles) > 0">
				<xsl:text>, &#10;		"alternateTitle": [</xsl:text>
				<xsl:for-each select="$var_titles">
					<xsl:if test="position() != 1">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:text>&#10;			"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
				</xsl:for-each>
				<xsl:if test="count($iss_title) > 1">
					<xsl:for-each select="$iss_title">
						<xsl:if test="position() != 1">
							<xsl:text>, &#10;			"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#10;		]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($iss_title) > 1">
					<xsl:text>, &#10;		"alternateTitle": [</xsl:text>
					<xsl:for-each select="$iss_title">
						<xsl:if test="position() != 1">
							<xsl:if test="position() > 2">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text>&#10;			"</xsl:text><xsl:value-of select="replace(replace(./rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>&#10;		]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="contribution_agents">
		<xsl:param name="node" />
		<xsl:variable name="contributor_count" select="count($node)" />
		<xsl:choose>
			<xsl:when test="$contributor_count = 1">
				<xsl:if test="$node/bf:agent/bf:Agent/rdfs:label/text()">
					<xsl:text>, &#10;		"contributor": {</xsl:text>
					<xsl:text> &#10;			"type": "</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
					<xsl:if test="starts-with($node/bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
						<xsl:text>, &#10;			"id": "</xsl:text><xsl:value-of select="$node/bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select="replace(replace($node/bf:agent/bf:Agent/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
					<xsl:text> &#10;		}</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$contributor_count > 1">
					<xsl:text>, &#10;		"contributor": [</xsl:text>
					<xsl:for-each select="$node">
						<xsl:if test="bf:agent/bf:Agent/rdfs:label/text()">
							<xsl:if test="position() != 1">
								<xsl:text>,</xsl:text>
							</xsl:if>
							<xsl:text> &#10;			{</xsl:text>
							<xsl:text> &#10;				"type": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/rdf:type/@rdf:resource" /><xsl:text>"</xsl:text>
							<xsl:if test="starts-with(bf:agent/bf:Agent/@rdf:about, 'http://www.viaf.org')">
								<xsl:text>, &#10;				"id": "</xsl:text><xsl:value-of select="bf:agent/bf:Agent/@rdf:about" /><xsl:text>"</xsl:text>
							</xsl:if>
							<xsl:text>, &#10;				"name": "</xsl:text><xsl:value-of select="replace(replace(bf:agent/bf:Agent/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
							<xsl:text> &#10;			}</xsl:text>
						</xsl:if>
					</xsl:for-each>
					<xsl:text> &#10;		]</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
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
					<xsl:text>, &#10;				"name": "</xsl:text><xsl:value-of select='replace(replace(./text(),$oneSlash,$twoSlash),$pPat,$pRep)' /><xsl:text>"</xsl:text>
					<xsl:text> &#10;			}</xsl:text>
				</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count($publishers) = 1" >
					<xsl:text>, &#10;		"publisher": {</xsl:text>
					<xsl:text> &#10;			"type": "http://id.loc.gov/ontologies/bibframe/Organization"</xsl:text>
					<xsl:text>, &#10;			"name": "</xsl:text><xsl:value-of select='replace(replace($publishers/text(),$oneSlash,$twoSlash),$pPat,$pRep)' /><xsl:text>"</xsl:text>
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
					<!--Create a set of unique language values present in the language structures, both with and without the identifiedBy structure-->
					<xsl:for-each select="$Work/bf:language/bf:Language/@rdf:about[generate-id() = generate-id(key('lang_combined',.)[1])] | $Work/bf:language/bf:Language/bf:identifiedBy/bf:Identifier/rdf:value/@rdf:resource[generate-id() = generate-id(key('lang_combined',.)[1])]">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			"</xsl:text><xsl:value-of select="substring(.,40)" /><xsl:text>"</xsl:text>
					</xsl:for-each>
				<xsl:text> &#10;		]</xsl:text>
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
								<xsl:text>, &#10;			"value": "</xsl:text><xsl:value-of select="replace(replace($lccn/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
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
						<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="replace(replace(./text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
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
	</xsl:template>

	<xsl:template name="is_n">
		<xsl:param name="base_path" />
		<xsl:param name="is_n" />
		<xsl:if test="$base_path/rdf:value">
			<xsl:choose>
				<xsl:when test="count($base_path[count(./bf:status) = 0 or ./bf:status/bf:Status/rdf:label/text() != 'invalid' or ./bf:status/bf:Status/rdf:label/text() != 'incorrect']) > 1">
					<xsl:text>, &#10;		"</xsl:text><xsl:value-of select="$is_n" /><xsl:text>": [</xsl:text>
					<xsl:for-each select="$base_path[count(./bf:status) = 0 or ./bf:status/bf:Status/rdf:label/text() != 'invalid' or ./bf:status/bf:Status/rdf:label/text() != 'incorrect']">
						<xsl:if test="position() != 1">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text> &#10;			"</xsl:text><xsl:value-of select="tokenize(./rdf:value/text(),' ')[position() = 1]" /><xsl:text>"</xsl:text>
					</xsl:for-each>
					<xsl:text> &#10;		]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="count($base_path/bf:status) = 0 or $base_path/bf:status/bf:Status/rdf:label/text() != 'invalid' or $base_path/bf:status/bf:Status/rdf:label/text() != 'incorrect'">
						<xsl:text>, &#10;		"</xsl:text><xsl:value-of select="$is_n" /><xsl:text>": "</xsl:text><xsl:value-of select="tokenize($base_path/rdf:value/text(),' ')[position() = 1]" /><xsl:text>"</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
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
						<xsl:text> &#10;			{</xsl:text>
						<xsl:text> &#10;				"type": "</xsl:text><xsl:value-of select="./rdf:type[1]/@rdf:resource" /><xsl:text>"</xsl:text>
						<xsl:if test="starts-with(./@rdf:about, 'http://id.loc.gov')">
							<xsl:text>, &#10;				"id": "</xsl:text><xsl:value-of select="./@rdf:about" /><xsl:text>"</xsl:text>
						</xsl:if>
						<xsl:text>, &#10;				"value": "</xsl:text><xsl:value-of select="replace(replace(./rdfs:label,$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
						<xsl:text> &#10;			}</xsl:text>
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
			<xsl:text>, &#10;			"journalTitle": "</xsl:text><xsl:value-of select="replace(replace($Work/bf:title[1]/bf:Title/rdfs:label/text(),$oneSlash,$twoSlash),$pPat,$pRep)" /><xsl:text>"</xsl:text>
			<xsl:text> &#10;		}</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>