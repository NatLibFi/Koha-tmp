-- This file is part of Koha.
--
-- Copyright 2011 Magnus Enger Libriotech
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License, or (at your option) any later
-- version.
--
-- Koha is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

INSERT IGNORE INTO biblio_framework VALUES ( 'FA','Hurtigkatalogisering' );

DELETE FROM marc_tag_structure WHERE frameworkcode='FA';
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('000','Postens hode','Postens hode','0','1','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('001','Identifikasjonsnummer','Identifikasjonsnummer','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('008','Informasjonskoder','Informasjonskoder','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('015','Andre bibliografiske kontrollnummer (R)','Andre bibliografiske kontrollnummer (R)','1','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('020','Internasjonalt standard boknummer (ISBN)','Internasjonalt standard boknummer (ISBN)','1','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('024','Andre standardnumre','Andre standardnumre','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('025','Europeisk artikkelnummer (EAN)','Europeisk artikkelnummer (EAN)','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('100','Hovedordningsord personnavn','Hovedordningsord personnavn','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('245','Tittel og ansvarsopplysninger','Tittel og ansvarsopplysninger','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('250','Utgave','Utgave','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('260','Utgivelse, distribusjon osv','Utgivelse, distribusjon osv','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('300','Fysisk beskrivelse','Fysisk beskrivelse','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('500','Generell note (R)','Generell note (R)','1','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('942','Andre opplysninger (Koha)','Andre opplysninger (Koha)','0','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('952','Eksemplarinformasjon (Koha)','Eksemplarinformasjon (Koha)','1','0','','FA');
INSERT INTO marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,frameworkcode) VALUES ('999','Kontrollnummer (Koha)','Kontrollnummer (Koha)','1','0','','FA');


DELETE FROM marc_subfield_structure WHERE frameworkcode='FA';
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('000','@','Postens hode','Postens hode','0','1','','0','','','normarc_leader.pl','0','-1','FA','','','','24');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('001','@','Identifikasjonsnummer','Identifikasjonsnummer','0','0','','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('008','@','Informasjonskoder','Informasjonskoder','0','0','','0','','','normarc_field_008.pl','0','-1','FA','','','','40');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('015','a','Nummer','Nummer','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('015','b','Kilde','Kilde','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('020','a','ISBN','ISBN','0','0','biblioitems.isbn','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('020','b','Innbindingsinformasjon','Innbindingsinformasjon','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('020','c','Leveringsbetingelser','Leveringsbetingelser','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('020','g','Andre tilf','Andre tilf','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('020','z','Feil ISBN','Feil ISBN','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('024','a','Standardnummer','Standardnummer','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('024','c','Leveringsbetingelser','Leveringsbetingelser','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('024','g','Andre tilføyelser','Andre tilføyelser','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('024','z','Feil standardnummer','Feil standardnummer','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('025','a','Nummer','Nummer','0','0','0','0','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','8','Andre karakteristika forbundet med navn','Andre karakteristika forbundet med navn','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','a','Navn','Navn','0','0','biblio.author','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','b','Nummer','Nummer','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','c','Andre tilføyelser','Andre tilføyelser','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','d','Årstall forbundet med navn','Årstall forbundet med navn','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','e','Betegnelse for funksjon','Betegnelse for funksjon','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','j','Nasjonalitet','Nasjonalitet','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','q','Mer fullstendig navneform','Mer fullstendig navneform','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('100','w','Sorteringsdelfelt for delfelt $a','Sorteringsdelfelt for delfelt $a','0','0','0','1','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('245','a','Tittel','Tittel','0','0','biblio.title','2','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('245','b','Annen tittelinformasjon','Annen tittelinformasjon','0','0','bibliosubtitle.subtitle','2','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('245','c','Ansvarsangivelse','Ansvarsangivelse','0','0','0','2','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('245','h','Generell materialbetegnelse','Generell materialbetegnelse','0','0','0','2','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('250','a','Utgave, opplag etc','Utgave, opplag etc','0','0','biblioitems.editionstatement','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('250','b','Ansvarshavende','Ansvarshavende','0','0','0','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','a','Sted (R)','Sted (R)','1','0','biblioitems.place','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','b','Navn p','Navn p','0','0','biblioitems.publishercode','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','c','År','År','0','0','biblio.copyrightdate','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','e','Trykkested eller produksjonssted','Trykkested eller produksjonssted','0','0','0','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','f','Trykkeriets eller produsentens navn','Trykkeriets eller produsentens navn','0','0','0','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('260','g','Trykkeår eller produksjonsår','Trykkeår eller produksjonsår','0','0','0','2','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('300','a','Omfang','Omfang','0','0','biblioitems.pages','3','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('300','b','Illustrasjonsmateriale og andre fysiske detaljer','Illustrasjonsmateriale og andre fysiske detaljer','0','0','biblioitems.illus','3','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('300','c','Format','Format','0','0','biblioitems.size','3','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('300','e','Bilag','Bilag','0','0','0','3','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('500','a','Notens tekst','Notens tekst','0','0','biblio.notes','5','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','0','Antall utlån','Antall utlån','0','0','biblioitems.totalissues','9','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','2','Kilde for klassifikasjon','Kilde for klassifikasjon','0','0','biblioitems.cn_source','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','6','Koha normalisert klassifikasjon for sortering','Koha normalisert klassifikasjon for sortering','0','0','biblioitems.cn_sort','-1','','','','0','7','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','c','Koha [standard] dokumenttype','Koha dokumenttype','0','1','biblioitems.itemtype','9','itemtypes','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','e','Utgave','Utgave','0','0','','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','h','Klassifikasjon del','Klassifikasjon del','0','0','biblioitems.cn_class','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','i','Eksemplar del','Eksemplar del','1','0','biblioitems.cn_item','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','k','Hyllesignatur prefiks','Hyllesignatur prefiks','0','0','','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','m','Hyllesignatur postfiks','Hyllesignatur postfiks','0','0','biblioitems.cn_suffix','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','n','Skjul i OPAC','Skjul i OPAC','0','0','','9','','','','0','-1','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('942','s','Periodikamark','Periodikamark','0','0','biblio.serial','9','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','0','Trukket tilbake','Trukket tilbake','0','0','items.withdrawn','10','WITHDRAWN','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','1','Tapt','Tapt','0','0','items.itemlost','10','LOST','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','2','Kilde for klassifikasjon','Kilde for klassifikasjon','0','0','items.cn_source','10','cn_source','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','3','Materialespesifikasjon (innbundet ','Materialespesifikasjon (innbundet ','0','0','items.materials','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','4','Skadet','Skadet','0','0','items.damaged','10','DAMAGED','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','5','Begrensninger p','Begrensninger p','0','0','items.restricted','10','RESTRICTED','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','6','Koha normalisert klassifikasjon for sortering','Koha normalisert klassifikasjon for sortering','0','0','items.cn_sort','-1','','','','0','7','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','7','Ikke til utlån','Ikke til utlån','0','0','items.notforloan','10','NOT_LOAN','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','8','Koha samling','Koha samling','0','0','items.ccode','10','CCODE','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','9','Koha eksemplarnummer (autogenerert)','Koha eksemplarnummer','0','0','items.itemnumber','-1','','','','0','7','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','a','Plassering (eiende filial)','Plassering (eiende filial)','0','0','items.homebranch','10','branches','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','b','Annen plassering (midlertidig filial)','Annen plassering (midlertidig filial)','0','0','items.holdingbranch','10','branches','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','c','Hylleplassering','Hylleplassering','0','0','items.location','10','LOC','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','d','Anskaffelsesdato','Anskaffelsesdato','0','0','items.dateaccessioned','10','','','dateaccessioned.pl','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','e','Kilde for anskaffelse','Kilde for anskaffelse','0','0','items.booksellerid','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','f','Kodet plasseringskvalifikator','Kodet plasseringskvalifikator','0','0','items.coded_location_qualifier','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','g','Pris (normal innkjøpspris)','Pris (normal innkjøpspris)','0','0','items.price','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','h','Serienummerering / kronologi','Serienummerering / kronologi','0','0','items.enumchron','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','j','Samling','Samling','0','0','items.stack','10','STACK','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','l','Koha utlån','Koha utlån','0','0','items.issues','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','m','Koha fornyinger','Koha fornyinger','0','0','items.renewals','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','n','Koha reserveringer','Koha reserveringer','0','0','items.reserves','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','o','Koha hyllesignatur','Koha hyllesignatur','0','0','items.itemcallnumber','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','p','Strekkode','Strekkode','0','0','items.barcode','10','','','barcode.pl','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','q','Koha utlånt','Koha utlånt','0','0','items.onloan','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','r','Koha dato sist sett','Koha dato sist sett','0','0','items.datelastseen','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','s','Koha dato sist utlånt','Koha dato sist utlånt','0','0','items.datelastborrowed','10','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','t','Eksemplarnummer','Eksemplarnummer','0','0','items.copynumber','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','u','Uniform Resource Identifier (URI)','Uniform Resource Identifier (URI)','0','0','items.uri','10','','','','1','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','v','Pris (erstatningspris)','Pris (erstatningspris)','0','0','items.replacementprice','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','w','Pris gjelder fra','Pris gjelder fra','0','0','items.replacementpricedate','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','x','Intern note','Intern note','1','0','items.itemnotes_nonpublic','10','','','','0','7','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','y','Koha dokumenttype','Koha dokumenttype','0','0','items.itype','10','itemtypes','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('952','z','Synlig note','Synlig note','0','0','items.itemnotes','10','','','','0','0','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('999','c','Koha biblionummer','Koha biblionummer','0','0','biblio.biblionumber','-1','','','','0','-5','FA','','','','9999');
INSERT INTO marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,authtypecode,value_builder,isurl,hidden,frameworkcode,seealso,link,defaultvalue,maxlength) VALUES ('999','d','Koha biblioitemnummer','Koha biblioitemnummer','0','0','biblioitems.biblioitemnumber','-1','','','','0','-5','FA','','','','9999');
