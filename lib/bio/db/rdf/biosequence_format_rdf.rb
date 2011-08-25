#
# = bio/db/rdf/biosequence_format_rdf.rb - RDF format generator for BioSequence object
#
# Copyright::  Copyright (C) 2011 Raoul J.P. Bonnal <r@bioruby.org>
# License::    The Ruby License
#
# $Id: biosequence_format_rdf.rb,v 1.1.2.5 2011/08/23 16:20:00 ngoto Exp $
#
require 'bio/sequence/format'
require 'cgi'
require 'rdf'
#require 'uuid'

#Supported output format are NTriples, RDFXML, N3
#These libraries must be installed to be used and are automatically required by this gem

module Bio
  class Reference
    def well_formed_sequence_position
      sequence_position.gsub(/-/," to ") unless sequence_position.nil?
    end
  end
end

module Bio::Sequence::Format::Formatter

  # Raw sequence output formatter class
  class Rdf < Bio::Sequence::Format::FormatterBase

    FORMATS ={:XML=>"RDFXML", :NTRIPLES=>"NTriples", :N3=>"N3", :JSON=>"JSON"}
    # helper methods
    include Bio::Sequence::Format::INSDFeatureHelper

    # INTERNAL USE ONLY, YOU SHOULD NOT CALL THIS METHOD.
    #
    # Creates a new my_format generater object from the sequence.
    #
    # The method code implemented here is dummy
    # and it works only as document place holder.
    #
    # ---
    # *Arguments*:
    # * _sequence_: Bio::Sequence object
    # * (optional) _opt_: (Hash) options. details of options may be
    #                     described as below.
    # * (optional) :title => _title_: (String) completely replaces
    #                                 title line with the _title_
    #                                 (default nil)
    # * (optional) :color => _color_: (String) color (default "ffffff")
    def initialize; super; end if false #dummy for RDoc


    def date_format
      format_date(date_modified || date_created || null_date)
    end

    def wrap_classification
      classification.join("; ")+"." unless classification.nil?
    end

    def well_formed_keywords
      keywords.empty? ? "." : keywords unless keywords.nil?
    end

    #TODO fix version in case of fasta
    def well_formed_version
      "#{primary_accession}.#{sequence_version}"+ ( respond_to?("ncbi_gi_number") ? " GI:#{ncbi_gi_number}" : "")
    end




    # <obf_item:locus>AB000100</obf_item:locus> type = "locus", field = "entry_id"
    # it can be there is no correspondence between the name you want to use (type) and the field in biosequence record you want to query
    # in case the type is also the name of the field you can call the method with only two parameter prefix and type
    #  rdf_item("obf","length")
    def rdf_item(prefix, type, field=type)
      "<#{prefix}:#{type}>#{self.send(field)}</#{prefix}:#{type}>"
    end


    # def rdf_statement(subject, vocabulary, type, field=type)
    #   RDF::Statement.new(subject, )
    # end

    #In the near futur it will return a graph, in the mean while it returns an array of statements
    def build_graph
      graph = RDF::Graph.new
      rdf=RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
      rdfs=RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
      dc=RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
      ddbj=RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/")
      ddbj_item=RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/core/item/")
      ddbj_qualifier=RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/core/qualifier/")
      ddbj_core = RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/core/") #resources
      ddbj_core_feature = RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/core/feature/") #resources
      dad=RDF::Vocabulary.new("http://sabi.ddbj.nig.ac.jp/dad/")
      ncbi=RDF::Vocabulary.new("http://www.ncbi.nih.gov/")

      entry_uri = RDF::URI.new("http://sabi.ddbj.nig.ac.jp/ddbj/data/#{entry_id}")

      graph << RDF::Statement.new(entry_uri, ddbj_item.locus, RDF::Literal.new(entry_id)) unless entry_id.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.length, RDF::Literal.new(length)) unless length.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.moltype, RDF::Literal.new(molecule_type)) unless molecule_type.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.topology, RDF::Literal.new(topology)) unless topology.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.division, RDF::Literal.new(division)) unless division.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.lastdate, RDF::Literal.new(date_format)) unless date_format.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.definition, RDF::Literal.new(definition)) unless definition.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.primary_accession, RDF::Literal.new(primary_accession)) unless primary_accession.nil? #TODO fix in case of FASTA input is not working properly.
      graph << RDF::Statement.new(entry_uri, ddbj_item.version, RDF::Literal.new(well_formed_version)) unless well_formed_version.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.keywords, RDF::Literal.new(well_formed_keywords)) unless well_formed_keywords.nil?
      graph << RDF::Statement.new(entry_uri, ddbj_item.source, RDF::Literal.new(species)) unless species.nil? #TODO fix is identical to organism
      graph << RDF::Statement.new(entry_uri, ddbj_item.organism, RDF::Literal.new(species)) unless species.nil? #TODO fix is ientical to source
      graph << RDF::Statement.new(entry_uri, ddbj_item.lineage, RDF::Literal.new(wrap_classification)) unless wrap_classification.nil?
      
      (references || []).each do |reference|
        reference_node = RDF::Node.new
        graph << RDF::Statement.new(entry_uri, ddbj_item.reference, reference_node)
        graph << RDF::Statement.new(reference_node, rdf.type, ddbj_core.reference) #resource
        graph << RDF::Statement.new(reference_node, ddbj_item.bases, RDF::Literal.new(reference.well_formed_sequence_position))
        graph << RDF::Statement.new(reference_node, ddbj_item.title, RDF::Literal.new(reference.title))
        graph << RDF::Statement.new(reference_node, ddbj_item.journal, RDF::Literal.new(reference.journal))
        author_node = RDF::Node.new
        graph << RDF::Statement.new(reference_node, ddbj_item.author, author_node)
        graph << RDF::Statement.new(author_node, rdf.type, rdf.Seq) #TODO create a seq generator
        reference.authors.each_with_index do |author, index|
          graph << RDF::Statement.new(author_node, rdf["_#{index+1}"], RDF::Literal(author))
        end #authors
      end # references
      features.each do |feature|
        feature_node = RDF::Node.new
        graph << RDF::Statement.new(entry_uri, ddbj_item.reference, feature_node)
        graph << RDF::Statement.new(feature_node, rdf.type, ddbj_core_feature[feature.feature]) #resource
        feature.qualifiers.each do |qualifier|
          graph << RDF::Statement.new(feature_node, ddbj_qualifier[qualifier.qualifier], qualifier.value)
        end #qualifiers
      end unless features.nil? #features
      
      #TODO is it correct ?
      comments_as_string = comments.is_a?(Array) ? comments.join : comments
      unless (comments_as_string.nil? || comments_as_string.empty?)
        comment_node = RDF::Node.new
        graph << RDF::Statement.new(entry_uri, ddbj_item.comment, comment_node)
        graph << RDF::Statement.new(comment_node, rdf.type, ddbj_core.comment)
        graph << RDF::Statement.new(comment_node, ddbj_item.comment, RDF::Literal.new(comments_as_string))
      end 
      if respond_to?("basecount")
        basecount.each do |base, count|
          graph << RDF::Statement.new(entry_uri, ddbj_item["base_count_#{base}"], RDF::Literal.new(base))
        end
      end #basecount old genbank
      graph << RDF::Statement.new(entry_uri, ddbj_item.origin, RDF::Literal.new(seq)) unless seq.nil?
      graph
    end #build

    def rdf_output_type
      (@options[:type] && FORMATS[@options[:type].upcase.intern]) || "NTriples"
    end
    
    def require_rdf_type
      require "rdf/#{rdf_output_type.downcase}"
    end
    
    def get_rdf_writer
      eval("RDF::#{rdf_output_type}::Writer")
    end
    
    #Options :type=>[:ntriples,:xml]
    #default is :ntriples
    def output
      #TODO ugly rewrite
      require_rdf_type
      writer_class = get_rdf_writer
      writer_class.buffer do |writer|
        build_graph.each_statement do |statement|
          writer << statement
        end
      end
    end
          end #class Rdf

end #module Bio::Sequence::Format::Formatter