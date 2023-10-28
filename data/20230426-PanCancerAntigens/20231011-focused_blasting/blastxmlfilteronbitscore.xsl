<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:strip-space elements="*"/>
<xsl:output 
	indent="yes"
	method="xml"
	standalone="no"
	doctype-public="-//NCBI//NCBI BlastOutput/EN" 
	doctype-system="http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd"
	/>

<xsl:param name="minimum-bit-score" select="40"/>

<xsl:template match="Hit">
	<xsl:if test="./Hit_hsps/Hsp/Hsp_bit-score &gt; $minimum-bit-score">
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>

<!-- identity transform -->
<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
