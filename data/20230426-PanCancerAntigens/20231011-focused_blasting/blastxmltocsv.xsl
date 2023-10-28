<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:strip-space elements="*"/>
<xsl:output 
	method="text"
	encoding="UTF-8"
	/>

<xsl:template match="@*|node()">
	<xsl:apply-templates select="@*|node()"/>
</xsl:template>


<xsl:template match="//Iteration">
	<xsl:for-each select="./Iteration_hits/Hit">
		<xsl:value-of select="../../Iteration_query-def"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_def"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_bit-score"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_evalue"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_query-from"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_query-to"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_hit-from"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_hit-to"/>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_qseq"/>
		<xsl:text>,</xsl:text><xsl:text>"</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_midline"/><xsl:text>"</xsl:text>
		<xsl:text>,</xsl:text><xsl:value-of select="Hit_hsps/Hsp/Hsp_hseq"/>
		<xsl:text>&#x0A;</xsl:text>
	</xsl:for-each>
</xsl:template>


<!--
<Iteration>
  <Iteration_iter-num>374</Iteration_iter-num>
  <Iteration_query-ID>Query_374</Iteration_query-ID>
  <Iteration_query-def>TCONS_00000246_HERVFH21-int_TAS1R1_+_104|373-398</Iteration_query-def>
  <Iteration_query-len>25</Iteration_query-len>
<Iteration_hits>
<Hit>
  <Hit_num>1</Hit_num>
  <Hit_id>YP_081561.1_HHV5_regulatory_protein_IE2</Hit_id>
  <Hit_def>YP_081561.1_HHV5_regulatory_protein_IE2</Hit_def>
  <Hit_accession>YP_081561.1_HHV5_regulatory_protein_IE2</Hit_accession>
  <Hit_len>580</Hit_len>
  <Hit_hsps>
    <Hsp>
      <Hsp_num>1</Hsp_num>
      <Hsp_bit-score>24.6386</Hsp_bit-score>
      <Hsp_score>52</Hsp_score>
      <Hsp_evalue>0.0310394</Hsp_evalue>
      <Hsp_query-from>5</Hsp_query-from>
      <Hsp_query-to>25</Hsp_query-to>
      <Hsp_hit-from>515</Hsp_hit-from>
      <Hsp_hit-to>535</Hsp_hit-to>
      <Hsp_query-frame>0</Hsp_query-frame>
      <Hsp_hit-frame>0</Hsp_hit-frame>
      <Hsp_identity>10</Hsp_identity>
      <Hsp_positive>13</Hsp_positive>
      <Hsp_gaps>0</Hsp_gaps>
      <Hsp_align-len>21</Hsp_align-len>
      <Hsp_qseq>QRFPHLVMLECTETNSLGFIL</Hsp_qseq>
      <Hsp_hseq>QKFPKQVMVRIFSTNQGGFML</Hsp_hseq>
      <Hsp_midline>Q+FP  VM+    TN  GF+L</Hsp_midline>
    </Hsp>
  </Hit_hsps>
</Hit>
</Iteration_hits>
</Iteration>
-->

</xsl:stylesheet>
