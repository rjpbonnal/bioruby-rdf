#
# test/unit/bio/db/genbank/test_genbank.rb - Unit test for Bio::GenBank
#
# Copyright::  Copyright (C) 2011 Raoul J.P. Bonnal <r@bioruby.org>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
# require 'helper'
# load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
#                             'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio'
require 'bio/sequence'
require 'bio/reference'
require 'bio/feature'
require 'bio/compat/features'
require 'bio/compat/references'
require 'bio/db/genbank/genbank'
require 'bio/db/genbank/genbank_to_biosequence'
require 'bio/db/rdf/biosequence_format_rdf'

module Bio
  class TestBioRdf < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'genbank', 'AB000100.gb')
      @obj = Bio::GenBank.new(File.read(filename))
      @seq = @obj.to_biosequence
      @formatter = Bio::Sequence::Format::Formatter::Rdf.new(@seq)
    end

    def test_rdf_default
      wf=File.open("test/data/results/test_default.txt",'w')
      wf.puts out = @seq.output(:rdf)
      wf.close
      assert_equal("", out)
    end
    
    def test_rdf_ntriples
      wf=File.open("test/data/results/test_ntriples.txt",'w')
      wf.puts out = @seq.output(:rdf, :type=>"ntriples")
      wf.close
      assert_equal("", out)
    end

    def test_rdf_xml
      wf=File.open("test/data/results/test_xml.txt",'w')
      wf.puts out = @seq.output(:rdf, :type=>"xml")
      wf.close
      assert_equal("", out)
    end
    
    def test_rdf_n3
      wf=File.open("test/data/results/test_n3.txt",'w')
      wf.puts out = @seq.output(:rdf, :type=>"n3")
      wf.close
      assert_equal("", out)
    end
    
    def test_rdf_json
      wf=File.open("test/data/results/test_json.txt",'w')
      wf.puts out = @seq.output(:rdf, :type=>"json")
      wf.close
      assert_equal("", out)
    end



 #    #test for bio_to_sequence
 #    def test_to_biosequence
 #      seq = @obj.to_biosequence
 #      expected_seq = "gatcctccatatacaacggtatctccacctcaggtttagatctcaacaacggaaccattgccgacatgagacagttaggtatcgtcgagagttacaagctaaaacgagcagtagtcagctctgcatctgaagccgctgaagttctactaagggtggataacatcatccgtgcaagaccaagaaccgccaatagacaacatatgtaacatatttaggatatacctcgaaaataataaaccgccacactgtcattattataattagaaacagaacgcaaaaattatccactatataattcaaagacgcgaaaaaaaaagaacaacgcgtcatagaacttttggcaattcgcgtcacaaataaattttggcaacttatgtttcctcttcgagcagtactcgagccctgtctcaagaatgtaataatacccatcgtaggtatggttaaagatagcatctccacaacctcaaagctccttgccgagagtcgccctcctttgtcgagtaattttcacttttcatatgagaacttattttcttattctttactctcacatcctgtagtgattgacactgcaacagccaccatcactagaagaacagaacaattacttaatagaaaaattatatcttcctcgaaacgatttcctgcttccaacatctacgtatatcaagaagcattcacttaccatgacacagcttcagatttcattattgctgacagctactatatcactactccatctagtagtggccacgccctatgaggcatatcctatcggaaaacaataccccccagtggcaagagtcaatgaatcgtttacatttcaaatttccaatgatacctataaatcgtctgtagacaagacagctcaaataacatacaattgcttcgacttaccgagctggctttcgtttgactctagttctagaacgttctcaggtgaaccttcttctgacttactatctgatgcgaacaccacgttgtatttcaatgtaatactcgagggtacggactctgccgacagcacgtctttgaacaatacataccaatttgttgttacaaaccgtccatccatctcgctatcgtcagatttcaatctattggcgttgttaaaaaactatggttatactaacggcaaaaacgctctgaaactagatcctaatgaagtcttcaacgtgacttttgaccgttcaatgttcactaacgaagaatccattgtgtcgtattacggacgttctcagttgtataatgcgccgttacccaattggctgttcttcgattctggcgagttgaagtttactgggacggcaccggtgataaactcggcgattgctccagaaacaagctacagttttgtcatcatcgctacagacattgaaggattttctgccgttgaggtagaattcgaattagtcatcggggctcaccagttaactacctctattcaaaatagtttgataatcaacgttactgacacaggtaacgtttcatatgacttacctctaaactatgtttatctcgatgacgatcctatttcttctgataaattgggttctataaacttattggatgctccagactgggtggcattagataatgctaccatttccgggtctgtcccagatgaattactcggtaagaactccaatcctgccaatttttctgtgtccatttatgatacttatggtgatgtgatttatttcaacttcgaagttgtctccacaacggatttgtttgccattagttctcttcccaatattaacgctacaaggggtgaatggttctcctactattttttgccttctcagtttacagactacgtgaatacaaacgtttcattagagtttactaattcaagccaagaccatgactgggtgaaattccaatcatctaatttaacattagctggagaagtgcccaagaatttcgacaagctttcattaggtttgaaagcgaaccaaggttcacaatctcaagagctatattttaacatcattggcatggattcaaagataactcactcaaaccacagtgcgaatgcaacgtccacaagaagttctcaccactccacctcaacaagttcttacacatcttctacttacactgcaaaaatttcttctacctccgctgctgctacttcttctgctccagcagcgctgccagcagccaataaaacttcatctcacaataaaaaagcagtagcaattgcgtgcggtgttgctatcccattaggcgttatcctagtagctctcatttgcttcctaatattctggagacgcagaagggaaaatccagacgatgaaaacttaccgcatgctattagtggacctgatttgaataatcctgcaaataaaccaaatcaagaaaacgctacacctttgaacaacccctttgatgatgatgcttcctcgtacgatgatacttcaatagcaagaagattggctgctttgaacactttgaaattggataaccactctgccactgaatctgatatttccagcgtggatgaaaagagagattctctatcaggtatgaatacatacaatgatcagttccaatcccaaagtaaagaagaattattagcaaaacccccagtacagcctccagagagcccgttctttgacccacagaataggtcttcttctgtgtatatggatagtgaaccagcagtaaataaatcctggcgatatactggcaacctgtcaccagtctctgatattgtcagagacagttacggatcacaaaaaactgttgatacagaaaaacttttcgatttagaagcaccagagaaggaaaaacgtacgtcaagggatgtcactatgtcttcactggacccttggaacagcaatattagcccttctcccgtaagaaaatcagtaacaccatcaccatataacgtaacgaagcatcgtaaccgccacttacaaaatattcaagactctcaaagcggtaaaaacggaatcactcccacaacaatgtcaacttcatcttctgacgattttgttccggttaaagatggtgaaaatttttgctgggtccatagcatggaaccagacagaagaccaagtaagaaaaggttagtagatttttcaaataagagtaatgtcaatgttggtcaagttaaggacattcacggacgcatcccagaaatgctgtgattatacgcaacgatattttgcttaattttattttcctgttttattttttattagtggtttacagataccctatattttatttagtttttatacttagagacatttaattttaattccattcttcaaatttcatttttgcacttaaaacaaagatccaaaaatgctctcgccctcttcatattgagaatacactccattcaaaattttgtcgtcaccgctgattaatttttcactaaactgatgaataatcaaaggccccacgtcagaaccgactaaagaagtgagttttattttaggaggttgaaaaccattattgtctggtaaattttcatcttcttgacatttaacccagtttgaatccctttcaatttctgctttttcctccaaactatcgaccctcctgtttctgtccaacttatgtcctagttccaattcgatcgcattaataactgcttcaaatgttattgtgtcatcgttgactttaggtaatttctccaaatgcataatcaaactatttaaggaagatcggaattcgtcgaacacttcagtttccgtaatgatctgatcgtctttatccacatgttgtaattcactaaaatctaaaacgtatttttcaatgcataaatcgttctttttattaataatgcagatggaaaatctgtaaacgtgcgttaatttagaaagaacatccagtataagttcttctatatagtcaattaaagcaggatgcctattaatgggaacgaactgcggcaagttgaatgactggtaagtagtgtagtcgaatgactgaggtgggtatacatttctataaaataaaatcaaattaatgtagcattttaagtataccctcagccacttctctacccatctattcataaagctgacgcaacgattactattttttttttcttcttggatctcagtcgtcgcaaaaacgtataccttctttttccgaccttttttttagctttctggaaaagtttatattagttaaacagggtctagtcttagtgtgaaagctagtggtttcgattgactgatattaagaaagtggaaattaaattagtagtgtagacgtatatgcatatgtatttctcgcctgtttatgtttctacgtacttttgatttatagcaaggggaaaagaaatacatactattttttggtaaaggtgaaagcataatgtaaaagctagaataaaatggacgaaataaagagaggcttagttcatcttttttccaaaaagcacccaatgataataactaaaatgaaaaggatttgccatctgtcagcaacatcagttgtgtgagcaataataaaatcatcacctccgttgcctttagcgcgtttgtcgtttgtatcttccgtaattttagtcttatcaatgggaatcataaattttccaatgaattagcaatttcgtccaattctttttgagcttcttcatatttgctttggaattcttcgcacttcttttcccattcatctctttcttcttccaaagcaacgatccttctacccatttgctcagagttcaaatcggcctctttcagtttatccattgcttccttcagtttggcttcactgtcttctagctgttgttctagatcctggtttttcttggtgtagttctcattattagatctcaagttattggagtcttcagccaattgctttgtatcagacaattgactctctaacttctccacttcactgtcgagttgctcgtttttagcggacaaagatttaatctcgttttctttttcagtgttagattgctctaattctttgagctgttctctcagctcctcatatttttcttgccatgactcagattctaattttaagctattcaatttctctttgatc"
 #      expected_id_namespace = "GenBank"
 #      expected_entry_id = "SCU49845"
 #      expected_primary_accession = "U49845"
 #      expected_secondary_accessions = []
 #      expected_other_seqids = ["1293613", "GI", []]
 #      expected_molecule_type = "DNA"
 #      expected_division = "PLN"
 #      expected_topology = "linear"
 #      expected_strandedness = nil
 #      expected_keywords = []
 #      expected_sequence_version = "1"
 #      expected_date_modified = "2010-03-23"
 #      expected_definition = "Saccharomyces cerevisiae TCP1-beta gene, partial cds; and Axl2p (AXL2) and Rev7p (REV7) genes, complete cds."
 #      expected_species = []
 #      expected_classification= ["Eukaryota", "Fungi", "Dikarya", "Ascomycota", "Saccharomyceta", "Saccharomycotina", "Saccharomycetes", "Saccharomycetales", "Saccharomycetaceae", "Saccharomyces"]
 #      expected_comments = ""
 #      expected_references = [{
 #  :abstract=>"",
 #  :affiliations=>[],
 #  :authors=>["Roemer, T.", "Madden, K.", "Chang, J.", "Snyder, M."],
 #  :comments=>nil,
 #  :doi=>nil,
 #  :embl_gb_record_number=>1,
 #  :issue=>"7",
 #  :journal=>"Genes Dev.",
 #  :medline=>"",
 #  :mesh=>[],
 #  :pages=>"777-793",
 #  :pubmed=>"8846915",
 #  :sequence_position=>"1-5028",
 #  :title=>
 #   "Selection of axial growth sites in yeast requires Axl2p, a novel plasma membrane glycoprotein",
 #  :url=>nil,
 #  :volume=>"10",
 #  :year=>"1996"},
 # 
 #  {:abstract=>"",
 #  :affiliations=>[],
 #  :authors=>["Roemer, T."],
 #  :comments=>nil,
 #  :doi=>nil,
 #  :embl_gb_record_number=>2,
 #  :issue=>"",
 #  :journal=>
 #   "Submitted (22-FEB-1996) Biology, Yale University, New Haven, CT 06520, USA",
 #  :medline=>"",
 #  :mesh=>[],
 #  :pages=>"",
 #  :pubmed=>"",
 #  :sequence_position=>"1-5028",
 #  :title=>"Direct Submission",
 #  :url=>nil,
 #  :volume=>"",
 #  :year=>""}]
 # 
 #      expected_features = [
 # {:feature=>"source",
 #  :position=>"1..5028",
 #  :qualifiers=>
 #   [{:qualifier=>"organism",
 #     :value=>"Saccharomyces cerevisiae"},
 #    {:qualifier=>"mol_type",
 #     :value=>"genomic DNA"},
 #    {:qualifier=>"db_xref",
 #     :value=>"taxon:4932"},
 #    {:qualifier=>"chromosome",
 #      :value=>"IX"}]},
 #  {:feature=>"mRNA",
 #   :position=>"<1..>206",
 #   :qualifiers=>
 #   [{   
 #     :qualifier=>"product",
 #     :value=>"TCP1-beta"}]},
 #  {:feature=>"CDS",
 #   :position=>"<1..206",
 #   :qualifiers=>   [{:qualifier=>"codon_start", :value=>3},    {:qualifier=>"product",     :value=>"TCP1-beta"},
 #    {:qualifier=>"protein_id",
 #     :value=>"AAA98665.1"},
 #    {:qualifier=>"db_xref",
 #     :value=>"GI:1293614"},
 #    {:qualifier=>"translation",
 #     :value=>
 #      "SSIYNGISTSGLDLNNGTIADMRQLGIVESYKLKRAVVSSASEAAEVLLRVDNIIRARPRTANRQHM"}]},
 #  {:feature=>"gene",
 #   :position=>"<687..>3158",
 #   :qualifiers=>
 #   [{:qualifier=>"gene", :value=>"AXL2"}]},
 #  {:feature=>"mRNA",
 #   :position=>"<687..>3158",
 #   :qualifiers=>
 #   [{:qualifier=>"gene", :value=>"AXL2"},
 #   {:qualifier=>"product",
 #    :value=>"Axl2p"}]},
 #  {:feature=>"CDS",
 #   :position=>"687..3158",
 #   :qualifiers=>
 #   [{:qualifier=>"gene", :value=>"AXL2"},
 #   {:qualifier=>"note",
 #    :value=>"plasma membrane glycoprotein"},
 #   {:qualifier=>"codon_start", :value=>1},   {:qualifier=>"product",
 #     :value=>"Axl2p"},
 #   {:qualifier=>"protein_id",
 #    :value=>"AAA98666.1"},
 #   {:qualifier=>"db_xref",
 #    :value=>"GI:1293615"},
 #   {:qualifier=>"translation",
 #    :value=>
 #      "MTQLQISLLLTATISLLHLVVATPYEAYPIGKQYPPVARVNESFTFQISNDTYKSSVDKTAQITYNCFDLPSWLSFDSSSRTFSGEPSSDLLSDANTTLYFNVILEGTDSADSTSLNNTYQFVVTNRPSISLSSDFNLLALLKNYGYTNGKNALKLDPNEVFNVTFDRSMFTNEESIVSYYGRSQLYNAPLPNWLFFDSGELKFTGTAPVINSAIAPETSYSFVIIATDIEGFSAVEVEFELVIGAHQLTTSIQNSLIINVTDTGNVSYDLPLNYVYLDDDPISSDKLGSINLLDAPDWVALDNATISGSVPDELLGKNSNPANFSVSIYDTYGDVIYFNFEVVSTTDLFAISSLPNINATRGEWFSYYFLPSQFTDYVNTNVSLEFTNSSQDHDWVKFQSSNLTLAGEVPKNFDKLSLGLKANQGSQSQELYFNIIGMDSKITHSNHSANATSTRSSHHSTSTSSYTSSTYTAKISSTSAAATSSAPAALPAANKTSSHNKKAVAIACGVAIPLGVILVALICFLIFWRRRRENPDDENLPHAISGPDLNNPANKPNQENATPLNNPFDDDASSYDDTSIARRLAALNTLKLDNHSATESDISSVDEKRDSLSGMNTYNDQFQSQSKEELLAKPPVQPPESPFFDPQNRSSSVYMDSEPAVNKSWRYTGNLSPVSDIVRDSYGSQKTVDTEKLFDLEAPEKEKRTSRDVTMSSLDPWNSNISPSPVRKSVTPSPYNVTKHRNRHLQNIQDSQSGKNGITPTTMSTSSSDDFVPVKDGENFCWVHSMEPDRRPSKKRLVDFSNKSNVNVGQVKDIHGRIPEML"}]},
 #  {:feature=>"gene",
 #   :position=>"complement(<3300..>4037)",
 #   :qualifiers=>
 #  [{:qualifier=>"gene", :value=>"REV7"}]},
 #  {:feature=>"mRNA",
 #   :position=>"complement(<3300..>4037)",
 #   :qualifiers=>
 #     [{:qualifier=>"gene", :value=>"REV7"},
 #     {:qualifier=>"product",
 #     :value=>"Rev7p"}]},
 #  {:feature=>"CDS",
 #   :position=>"complement(3300..4037)",
 #   :qualifiers=>
 #   [{:qualifier=>"gene", :value=>"REV7"},
 #    {:qualifier=>"codon_start", :value=>1},
 #    {:qualifier=>"product",
 #     :value=>"Rev7p"},
 #    {:qualifier=>"protein_id",
 #     :value=>"AAA98667.1"},
 #    {:qualifier=>"db_xref",
 #     :value=>"GI:1293616"},
 #    {:qualifier=>"translation",
 #     :value=>
 #      "MNRWVEKWLRVYLKCYINLILFYRNVYPPQSFDYTTYQSFNLPQFVPINRHPALIDYIEELILDVLSKLTHVYRFSICIINKKNDLCIEKYVLDFSELQHVDKDDQIITETEVFDEFRSSLNSLIMHLEKLPKVNDDTITFEAVINAIELELGHKLDRNRRVDSLEEKAEIERDSNWVKCQEDENLPDNNGFQPPKIKLTSLVGSDVGPLIIHQFSEKLISGDDKILNGVYSQYEEGESIFGSLF"}]}]
 # 
 #      assert_equal(expected_seq, seq.seq)
 #      assert_equal(expected_id_namespace, seq.id_namespace)
 #      assert_equal(expected_entry_id, seq.entry_id)
 #      assert_equal(expected_primary_accession, seq.primary_accession)
 #      assert_equal(expected_secondary_accessions, seq.secondary_accessions)
 #      seqids = seq.other_seqids.first
 #      actual_other_seqids = [seqids.id, seqids.database, seqids.secondary_ids]
 #      assert_equal(expected_other_seqids, actual_other_seqids)
 #      assert_equal(expected_division, seq.division)
 #      assert_equal(expected_strandedness, seq.strandedness)
 #      assert_equal(expected_keywords, seq.keywords)
 #      assert_equal(expected_classification, seq.classification)
 #      assert_equal(expected_comments, seq.comments)
 #      refs = seq.references
 #      actual_references = []
 #      refs.each do |ref|
 #       actual_references << {:abstract => ref.abstract,
 #                             :affiliations => ref.affiliations,
 #                             :authors => ref.authors,
 #                             :comments => ref.comments,
 #                             :doi => ref.doi,
 #                             :embl_gb_record_number => ref.embl_gb_record_number,
 #                             :issue => ref.issue,
 #                             :journal =>  ref.journal,
 #                             :medline => ref.medline,
 #                             :mesh => ref.mesh,
 #                             :pages => ref.pages,
 #                             :pubmed => ref.pubmed,
 #                             :sequence_position => ref.sequence_position,
 #                             :title => ref.title,
 #                             :url => ref.url,
 #                             :volume => ref.volume,
 #                             :year => ref.year}
 #      end
 #      assert_equal(expected_references, actual_references)
 #      fets = seq.features
 #      actual_features = []
 #      fets.each do |fet|
 #        feature = fet.feature
 #        position = fet.position
 #        quals = []
 #        fet.qualifiers.each do |qual|
 #          quals << {:qualifier => qual.qualifier, :value => qual.value}
 #        end
 #      actual_features << {:feature => feature, :position => position, :qualifiers => quals}
 #      end
 #      assert_equal(expected_features, actual_features) # skip
 #      
 # 
 #    end

  end #class TestBioGenBank
end #module Bio

