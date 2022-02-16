<?xml version="1.0" encoding="utf-8"?>

<!-- This file must be saved in UTF8 encoding with proper UTF8 byte order mark -->

<xslt:stylesheet version="1.0" xmlns:xslt="http://www.w3.org/1999/XSL/Transform">
  <xslt:output method="html" version="1.0" encoding="utf-8"/>

  <!-- Helper functions for generating links, javascript and css declarations -->
  <xslt:include href="default/common.xslt"/>
  
  <xslt:template match="/">
    <xslt:text disable-output-escaping="yes">&lt;!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"&gt;</xslt:text>
    <html>
      <head>
        <script type="text/javascript">
          <xslt:call-template name="javascript"/>
        </script>
        <xslt:call-template name="buildCSS"/> 
      </head>
      <body minwidth="0" minheight="0" maxwidth="0" maxheight="0" debug="0" allcontacts="0">
		<table cellpadding="0" cellspacing="0" width="100%" class="maintable">
			<tr>
				<td valign="top">
					<table cellpadding="0" cellspacing="0">
						<xslt:call-template name="Company">
							<xslt:with-param name="Company" select="XSLT/Contact/Company"/>
							<xslt:with-param name="Department" select="XSLT/Contact/Department"/>
						</xslt:call-template>
						<xslt:call-template name="RemoteContactInformation">
							<xslt:with-param name="Businessstreet" select="XSLT/Contact/BusinessAddressStreet"/>
							<xslt:with-param name="Businesscity" select="concat(XSLT/Contact/BusinessAddressPostalCode, ' ', XSLT/Contact/BusinessAddressCity)"/>
							<xslt:with-param name="Businesscountry" select="concat(XSLT/Contact/BusinessAddressState, ' ', XSLT/Contact/BusinessAddressCountry)"/>
							<xslt:with-param name="Privatestreet" select="XSLT/Contact/PrivateAddressStreet"/>
							<xslt:with-param name="Privatecity" select="concat(XSLT/Contact/PrivateAddressPostalCode, ' ', XSLT/Contact/PrivateAddressCity)"/>
							<xslt:with-param name="Privatecountry" select="concat(XSLT/Contact/PrivateAddressState, ' ', XSLT/Contact/PrivateAddressCountry)"/>
						</xslt:call-template>
					</table>
				</td>
				<xslt:if test ="normalize-space(XSLT/General/PicturePresenceHeight) = '16' and XSLT/Contact/binarydata/jpegPhoto">
				  <td align="right">
					<span style="display:none;">PCE-2562</span>
					<xslt:element name="img">
					  <xslt:attribute name="src">RemoteContact!jpegPhoto</xslt:attribute>
					</xslt:element>
				  </td>
				</xslt:if>
			</tr>

          <!-- Web link example -->
          <!--
            <xslt:if test="normalize-space(XSLT/Contact/WebPageURL) != ''">
              <tr><td>
              <xslt:call-template name="buildlink">
                <xslt:with-param name="linkadress" select="XSLT/Contact/WebPageURL"/>
                <xslt:with-param name="linktext" select="XSLT/Contact/WebPageURL"/>
                <xslt:with-param name="target">_blank</xslt:with-param>
              </xslt:call-template>
              </td></tr>
            </xslt:if>
          -->
	    <!-- Test links -->
					<tr><td>
						<xslt:variable name="openAccounturl" select="XSLT/Contact/Custom0"/>
						<img src="http://server:8888/salesforce_logo.png" />&#160;<a href="chromeurl:https://www.bkm.be" target="browserLauncher">Open with Chrome</a>
						<xslt:variable name="createContactAccounturl" select="XSLT/Contact/Custom5"/>
						<br /><img src="http://server:8888/salesforce_logo.png" />&#160;<a href="firefoxurl:https://www.bkm.be" target="browserLauncher">Open with Firefox</a>
						<xslt:variable name="openTaskurl" select="XSLT/Contact/Custom3"/>
						<br /><img src="http://server:8888/salesforce_logo.png" />&#160;<a href="microsoft-edge:https://www.bkm.be" target="browserLauncher">Open with Edge</a>
					</td></tr>
         </table>
	 <iframe name="browserLauncher" src="#" style="position: absolute;width:0;height:0;border:0;"></iframe>
      </body>
    </html>
  </xslt:template>
 
  <xslt:template name="Company">
    <xslt:param name="Company"/>
    <xslt:param name="Department"/>
    <xslt:if test="$Company != ''">
      <tr><td class="boldfont"><xslt:value-of select="concat($Company, ' ', $Department)"/></td></tr>
    </xslt:if>
  </xslt:template>
      
 <xslt:template name="RemoteContactInformation">
    <xslt:param name="Businessstreet"/>
    <xslt:param name="Businesscity"/>
    <xslt:param name="Businesscountry"/>
    <xslt:param name="Privatestreet"/>
    <xslt:param name="Privatecity"/>
    <xslt:param name="Privatecountry"/>
    <xslt:choose>
      <xslt:when test="normalize-space($Businessstreet) = '' and normalize-space($Privatestreet) = ''">
        <xslt:choose>
          <xslt:when test="normalize-space($Businesscity) != ''">    
            <tr><td><xslt:value-of select="$Businesscity"/> - <xslt:value-of select="$Businesscountry"/></td></tr>
          </xslt:when>
          <xslt:when test="normalize-space($Privatecity) != ''">    
            <tr><td><xslt:value-of select="$Privatecity"/> - <xslt:value-of select="$Privatecountry"/></td></tr>       
          </xslt:when>
        </xslt:choose>
      </xslt:when>
      <xslt:when test="normalize-space($Businesscity) != ''">    
        <tr><td><xslt:value-of select="$Businessstreet"/></td></tr>
        <tr><td><xslt:value-of select="$Businesscity"/></td></tr>
        <tr><td><xslt:value-of select="$Businesscountry"/></td></tr>       
      </xslt:when>
      <xslt:when test="normalize-space($Privatecity) != ''">    
        <tr><td><xslt:value-of select="$Privatestreet"/></td></tr>
        <tr><td><xslt:value-of select="$Privatecity"/></td></tr>
        <tr><td><xslt:value-of select="$Privatecountry"/></td></tr>       
      </xslt:when>
    </xslt:choose>
  </xslt:template>
</xslt:stylesheet>