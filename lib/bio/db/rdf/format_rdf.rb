#
# = bio/db/redf/format_rdf.rb - RDF format generator for BioSequence object
#
# Copyright::  Copyright (C) 2011 Raoul J.P. Bonnal <r@bioruby.org>
# License::    The Ruby License
#
# $Id: format_rdf.rb,v 1.1.2.5 2011/08/23 16:20:00 ngoto Exp $
#

require 'bio/sequence/format'

require 'bio/sequence/format'
require 'cgi'
require 'rdf'
require 'rdf/ntriples'
#require 'uuid'

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

    def e(str)
      CGI.escapeHTML(str)
    end

    def rdf_header
      <<'__RDF_HEADER__'
      <rdf:RDF
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:ddbj="http://sabi.ddbj.nig.ac.jp/"
      xmlns:ddbj_item="http://sabi.ddbj.nig.ac.jp/core/item/"
      xmlns:ddbj_qualifier="http://sabi.ddbj.nig.ac.jp/core/qualifier/"
      xmlns:dad="http://sabi.ddbj.nig.ac.jp/dad/"
      xmlns:ncbi="http://www.ncbi.nih.gov/"
      >
__RDF_HEADER__
    end

    def rdf_tail
      <<'__RDF_TAIL__'
      </rdf:RDF>
__RDF_TAIL__
    end

    def rdf_body
    end

    def date_format
      format_date(date_modified || date_created || null_date)
    end

    def wrap_classification
      classification.join("; ")+"."
    end

    def well_formed_keywords
      keywords.empty? ? "." : keywords
    end

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


    def rdf_statement(subject, vocabulary, type, field=type)
      RDF::Statement.new(subject, )
    end

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

      graph << RDF::Statement.new(entry_uri, ddbj_item.locus, RDF::Literal.new(entry_id))
      graph << RDF::Statement.new(entry_uri, ddbj_item.length, RDF::Literal.new(length))
      graph << RDF::Statement.new(entry_uri, ddbj_item.moltype, RDF::Literal.new(molecule_type))
      graph << RDF::Statement.new(entry_uri, ddbj_item.topology, RDF::Literal.new(topology))
      graph << RDF::Statement.new(entry_uri, ddbj_item.division, RDF::Literal.new(division))
      graph << RDF::Statement.new(entry_uri, ddbj_item.lastdate, RDF::Literal.new(date_format))
      graph << RDF::Statement.new(entry_uri, ddbj_item.definition, RDF::Literal.new(definition))
      graph << RDF::Statement.new(entry_uri, ddbj_item.primary_accession, RDF::Literal.new(primary_accession))
      graph << RDF::Statement.new(entry_uri, ddbj_item.version, RDF::Literal.new(well_formed_version))
      graph << RDF::Statement.new(entry_uri, ddbj_item.keywords, RDF::Literal.new(well_formed_keywords))
      graph << RDF::Statement.new(entry_uri, ddbj_item.source, RDF::Literal.new(species)) #TODO fix is identical to organism
      graph << RDF::Statement.new(entry_uri, ddbj_item.organism, RDF::Literal.new(species))#TODO fix is ientical to source
      graph << RDF::Statement.new(entry_uri, ddbj_item.lineage, RDF::Literal.new(wrap_classification))
      
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
      end #features
      
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
      graph << RDF::Statement.new(entry_uri, ddbj_item.origin, RDF::Literal.new(seq))
      graph
    end #build

    def output
      #TODO ugly rewrite
      RDF::NTriples::Writer.buffer do |writer|
        build.each_statement do |statement|
          writer << statement
        end
      end
    end

    private :e


    ## WARING
    #TODO:FIX source and organism are NOT the same in genbank' specifications
    #TODO:FIX there is an issue with authors, each time I create an rdf:li there is an add newline

    # output rdf sequence data
  #   erb_template <<'__RDF_TEMPLATE__'
  #     <%= rdf_header %>
  #     <rdf:Description rdf:about="http://sabi.ddbj.nig.ac.jp/ddbj/data/<%= entry_id %>">
  #     <%= rdf_item("obf_item","locus","entry_id") %>
  #     <%= rdf_item("obf_item","length") %>
  #     <%= rdf_item("obf_item","moltype", "molecule_type") %>
  #     <%= rdf_item("obf_item","topology") %>
  #     <%= rdf_item("obf_item","division") %>
  #     <%= rdf_item("obf_item","lastdate","date_format") %>
  #     <%= rdf_item("obf_item","definition") %>
  #     <%= rdf_item("obf_item","primary_accession") %>
  #     <%= rdf_item("obf_item","version","well_formed_version") %>
  #     <%= rdf_item("obf_item","keywords", "well_formed_keywords") %>
  #     <%= rdf_item("obf_item","source","species") %>
  #     <%= rdf_item("obf_item","organism","species") %>
  #     <%= rdf_item("obf_item","lineage","wrap_classification") %>
  # 
  #     <%  n = 0
  #     (references || []).each do |reference| 
  #       n += 1
  #       %>
  #       <obf_item:reference>                                 
  #       <rdf:Description>
  #       <rdf:type rdf:resource="http://sabi.ddbj.nig.ac.jp/core/reference" />
  #       <obf_item:bases><%= reference.well_formed_sequence_position %></obf_item:bases>
  #       <obf_item:author>
  #       <rdf:Seq>
  #       <% reference.authors.each do |author| %>
  #         <rdf:li><%= author.chomp %></rdf:li>
  #         <% end %>
  #         </rdf:Seq>
  #         </obf_item:author>
  #         <obf_item:title><%= reference.title %></obf_item:title>
  #         <obf_item:journal><%= reference.journal %></obf_item:journal>
  # 
  #         </rdf:Description>
  #         </obf_item:reference>
  #         <% end %>
  # 
  #         <% features.each do |feature| %>
  # 
  #           <obf_item:feature>
  #           <rdf:Description>
  #           <rdf:type rdf:resource="http://sabi.ddbj.nig.ac.jp/core/feature/<%= feature.feature %>" />
  #           <obf_qualifier:location><%= feature.position %></obf_qualifier:location>
  #           <% feature.qualifiers.each do |qualifier| %>
  #             <obf_qualifier:<%= qualifier.qualifier %>><%= qualifier.value %></obf_qualifier:<%= qualifier.qualifier %>>
  #             <% end %>
  #             </rdf:Description>
  #             </obf_item:feature>
  #             <% end %>
  # 
  #             </rdf:Description>
  #             <%= rdf_tail %>
  # __RDF_TEMPLATE__

          end #class Rdf

        end #module Bio::Sequence::Format::Formatter

        # <ddbj_item:locus>AB000100</ddbj_item:locus>
        #   <ddbj_item:length>2992</ddbj_item:length>
        #   <ddbj_item:moltype>DNA</ddbj_item:moltype>
        #   <ddbj_item:topology>linear</ddbj_item:topology>
        #   <ddbj_item:division>BCT</ddbj_item:division>
        #   <ddbj_item:lastdate>15-MAY-2009</ddbj_item:lastdate>
        #   <ddbj_item:definition>Synechococcus elongatus PCC 7942 genes for intrinsic membrane protein, malK-like protein, cyanase, complete cds.</ddbj_item:definition>
        #   <ddbj_item:primary_accession>AB000100</ddbj_item:primary_accession>
        #   <ddbj_item:version>AB000100.1</ddbj_item:version>
        #   <ddbj_item:keywords>.</ddbj_item:keywords>
        #   <ddbj_item:source>Synechococcus elongatus PCC 7942</ddbj_item:source>
        #   <ddbj_item:organism>Synechococcus elongatus PCC 7942</ddbj_item:organism>
        #   <ddbj_item:lineage>Bacteria; Cyanobacteria; Chroococcales; Synechococcus.</ddbj_item:lineage>




        # Erb template of GenBank format for Bio::Sequence
        #     erb_template <<'__END_OF_TEMPLATE__'
        # LOCUS       <%= sprintf("%-16s", entry_id) %> <%= sprintf("%11d", length) %> bp <%= sprintf("%3s", strandedness_genbank) %><%= sprintf("%-6s", mol_type_genbank) %>  <%= sprintf("%-8s", topology) %><%= sprintf("%4s", division) %> <%= date_format_genbank %>
        # DEFINITION  <%= genbank_wrap_dot(definition.to_s) %>
        # ACCESSION   <%= genbank_wrap(([ primary_accession ] + (secondary_accessions or [])).join(" ")) %>
        # VERSION     <%= primary_accession %>.<%= sequence_version %><% if gi = ncbi_gi_number then %>  GI:<%= gi %><% end %>
        # KEYWORDS    <%= genbank_wrap_dot((keywords or []).join('; ')) %>
        # SOURCE      <%= genbank_wrap(species) %>
        #   ORGANISM  <%= genbank_wrap(species) %>
        #             <%= genbank_wrap_dot((classification or []).join('; ')) %>
        # <% 
        #     n = 0
        #     (references or []).each do |ref|
        #       n += 1
        # %><%= reference_format_genbank(ref, n) %><%
        #     end
        # %><%= comments_format_genbank(comments)
        # %>FEATURES             Location/Qualifiers
        # <%= format_features_genbank(features || [])
        #  %>ORIGIN
        # <%= seq_format_genbank(seq)
        #  %>//
        # __END_OF_TEMPLATE__
