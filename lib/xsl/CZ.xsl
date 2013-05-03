<?xml version="1.0" encoding="utf-8"?>
<xsl:transform 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:gn="urn:x-inspire:specification:gmlas:GeographicalNames:3.0" 
xmlns:gml3="http://www.opengis.net/gml/3.2" 
xmlns:xlink="http://www.w3.org/1999/xlink" 
xmlns:gco="http://www.isotc211.org/2005/gco" 
xmlns:CP="urn:x-inspire:specification:gmlas:CadastralParcels:3.0" 
xmlns:gmd="http://www.isotc211.org/2005/gmd" 
xmlns:base="urn:x-inspire:specification:gmlas:BaseTypes:3.2"
version="1.0" >
  <xsl:template match="/">
	<ogr:FeatureCollection xmlns:xsi="http://www.w3c.org/2001/XMLSchema-instance"  xmlns:ogr="http://ogr.maptools.org/" xmlns:gml="http://www.opengis.net/gml" xmlns="http://ogr.maptools.org/" xsi:schemaLocation=". CZ.xsd">
		<xsl:for-each select="//CP:CadastralZoning">
			<gml:featureMember>
		    <CadastralZoning fid="{position()}">
			<beginLifespanVersion><xsl:value-of select="CP:beginLifespanVersion"/></beginLifespanVersion>
			<localId><xsl:value-of select="CP:inspireId/base:Identifier/base:localId"/></localId>
			<label><xsl:value-of select="CP:label"/></label>
			<nationalCadastalZoningReference><xsl:value-of select="CP:nationalCadastalZoningReference"/></nationalCadastalZoningReference>
			<referencePoint><xsl:value-of select="CP:referencePoint/gml3:Point/gml3:pos"/></referencePoint>
	        <ogr:geometryProperty>
            <gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates>
			<xsl:variable name="cor" select="CP:geometry/gml3:MultiSurface/gml3:surfaceMember/gml3:Polygon/gml3:exterior/gml3:LinearRing/gml3:posList"/>
			<xsl:call-template name="splitBySpace">
	            <xsl:with-param name="str" select="$cor"/>
				<xsl:with-param name="por" select="1"/>
	        </xsl:call-template>
			</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon>
			</ogr:geometryProperty>
			</CadastralZoning>
			</gml:featureMember>
			<xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
	</ogr:FeatureCollection>
  </xsl:template>
  <xsl:template name="splitBySpace">
    <xsl:param name="str"/>
	<xsl:param name="por"/>
    <xsl:choose>
      <xsl:when test="contains($str,' ')">
	      <xsl:value-of select="substring-before($str,' ')"/>
		  <xsl:if test="$por mod 2 > 0"><xsl:text>,</xsl:text></xsl:if>
		  <xsl:if test="$por mod 2 = 0"><xsl:text> </xsl:text></xsl:if>
	      <xsl:call-template name="splitBySpace">
	        <xsl:with-param name="str" select="substring-after($str,' ')"/>
			<xsl:with-param name="por" select="$por + 1"/>
	      </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
		<xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
