#! /usr/bin/ruby
## -*- cofing:utf-8 -*-
#
#  『DBTSS RDF Converter』alpha version 0.1
#   by Yusuke Komiyama
#
#  ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-darwin11.4.0]
#
require 'rdf' 
require 'rdf/ntriples'
require 'csv'
require 'net/ftp'
require 'optparse'
require 'mysql'
include RDF

RDF::Writer.open("./result/dbtss_tss.nt") do |writer|
client= Mysql.connect('localhost', 'root', 'mysql', 'mysql')
client.query("select * from tss_bincount_9606_chr18_LC2ad limit 1").each do |col1,col2,col3,col4,col5,col6,col7,col8,col9|
#print col1,",",col2,",",col3,",",col4,",",col5,",",col6,",",col7,",",col8,",",col9,"\n" 

  #########################################################
  #  TSS Convert
  #########################################################

    #########################################################
    #  define PREFIX
    #########################################################
    dbtss = RDF::Vocabulary.new("http://dbtss.hgc.jp/rdf/")
    tsso = RDF::Vocabulary.new("http://dbtss.hgc.jp/ontology/")
    edam = RDF::Vocabulary.new("http://edamontology.org/")
 #   pdbo = RDF::Vocabulary.new("http://rdf.wwpdb.org/schema/pdbx-v40.owl#")
 #   pdbr = RDF::Vocabulary.new("http://rdf.wwpdb.org/pdb/")
 #   up = RDF::Vocabulary.new("http://purl.uniprot.org/core/")
 #   upr = RDF::Vocabulary.new("http://purl.uniprot.org/uniprot/")
    rdf = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    rdfs = RDF::Vocabulary.new("http://www.w3.org/TR/rdf-schema/#")
    idorg = RDF::Vocabulary.new("http://info.identifiers.org/")
    faldo = RDF::Vocabulary.new("http://biohackathon.org/resource/faldo#")
    obo = RDF::Vocabulary.new("http://purl.obolibrary.org/obo/")
    efo = RDF::Vocabulary.new("http://www.ebi.ac.uk/efo/")
    tmo = RDF::Vocabulary.new("http://www.w3.org/2001/sw/hcls/ns/transmed/")
    dcterms = RDF::Vocabulary.new("http://purl.org/dc/terms/")
    ncit = RDF::Vocabulary.new("http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#")
    owl = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")
    sio = RDF::Vocabulary.new("http://semanticscience.org/resource/")
 #   ut = RDF::Vocabulary.new("http://utprot.net/")

    #########################################################
    #  constraction of RDF model
    #########################################################
	gversion = "hg38"
	tss_ver = "9.0"
	tissue = "LC2ad"

	if /F/ =~ col5
	  strand = "+"
	elsif /R/ =~ col5
	  strand = "-"
	end

	dbtss_resouce = dbtss.to_s + gversion + "-" + col3.to_s + ":" + col4.to_s + ":" + strand.to_s  + "::"
	dbtss_uri = RDF::URI.new(dbtss_resouce)

#	print dbtss_uri + "\n"

	dbtss_tss = dbtss.to_s + tss_ver + "/" + tissue.to_s + "/" + col1.to_s + "/" + gversion + "-" + col3.to_s + ":" + col4.to_s + ":" + strand.to_s  + "::" 
	dbtss_tss_uri = RDF::URI.new(dbtss_tss)

#	print dbtss_tss + "\n"

  writer << RDF::Graph.new do |graph|
 
    # TSS Position
    graph.insert([dbtss_uri, rdf.type, faldo.Region])

    bnode1 = RDF::Node.uuid.to_s.insert(0,"exactpos").delete("-").delete("_:")
    bnode1 = RDF::Node.new(bnode1)

    graph.insert([dbtss_uri, faldo.location, bnode1])
    graph.insert([bnode1, rdf.type, faldo.ExactPosition])
    graph.insert([bnode1, faldo.begin, col4])
    graph.insert([bnode1, faldo.end, col4])

    bnode2 = RDF::Node.uuid.to_s.insert(0,"tsspos").delete("-").delete("_:")
    bnode2 = RDF::Node.new(bnode2)

    graph.insert([bnode1, faldo.reference, bnode2])

    graph.insert([bnode2, dcterms.identifier, col3])
#    graph.insert([bnode2, obo.RO_0002162, idorg.taxonomy/9606])
    graph.insert([bnode2, tsso.assembly, gversion])
 

#=begin
    # TSS gene
    bnode3 = RDF::Node.uuid.to_s.insert(0,"dbtss_ver").delete("-").delete("_:")
    bnode3 = RDF::Node.new(bnode3)
    bnode4 = RDF::Node.uuid.to_s.insert(0,"dbtss_rep").delete("-").delete("_:")
    bnode4 = RDF::Node.new(bnode4)
    bnode5 = RDF::Node.uuid.to_s.insert(0,"dbtss_cnt").delete("-").delete("_:")
    bnode5 = RDF::Node.new(bnode5)

    graph.insert([dbtss_tss_uri, rdf.type, obo.SO_0000315])
    graph.insert([dbtss_tss_uri, dcterms.hasVersion, bnode3])
    	graph.insert([bnode3, rdf.type, edam.data_1670])
    	graph.insert([bnode3, rdfs.label, tss_ver])
    graph.insert([dbtss_tss_uri, owl.hasValue, bnode4])
	graph.insert([bnode4, rdf.type, ncit.C67045])
    	graph.insert([bnode4, rdfs.label, col9])
    graph.insert([dbtss_tss_uri, owl.hasValue, bnode5])
	graph.insert([bnode5, rdf.type, sio.SIO_000794])
    	graph.insert([bnode5, rdfs.label, col6])
    graph.insert([dbtss_tss_uri, dcterms.source, efo.EFO_0003140])

    graph.insert([dbtss_tss_uri, faldo.location, dbtss_uri])
#=end
  
  end
end
end

