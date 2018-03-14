# frozen_string_literal: true

RSpec.describe Stanford::Mods::Normalizer do
  it 'has a version number' do
    expect(Stanford::Mods::Normalizer::VERSION).not_to be nil
  end

  let(:normalizer) { described_class.new }

  describe 'clean_text' do
    it 'formats text blocks correctly' do
      bad_string = "       This is		some text		with more


than 		one


problem

	inside

"
      expect(normalizer.clean_text(bad_string)).to eq('This is some text with more than one problem inside')
    end

    it 'returns nil given a nil input' do
      expect(normalizer.clean_text(nil)).to eq(nil)
    end

    it 'returns nil given an empty string' do
      expect(normalizer.clean_text('')).to eq(nil)
    end

    it 'returns an empty string given an input that is only whitespace' do
      expect(normalizer.clean_text('   ')).to eq('')
    end
  end

  describe 'exceptional?' do
    it 'returns false for a nil input' do
      expect(normalizer.exceptional?(nil)).to be_falsey
    end

    it 'returns false for an element that does not have any attributes' do
      no_attributes_doc = Nokogiri::XML('<root_node><typeOfResource>randomtext</typeOfResource></root_node>')
      expect(normalizer.exceptional?(no_attributes_doc.root.children[0])).to be_falsey
    end

    it 'returns true for an element that matches the condition' do
      exceptional_doc = Nokogiri::XML('<root_node><typeOfResource collection="yes">randomtext</typeOfResource></root_node>')
      expect(normalizer.exceptional?(exceptional_doc.root.children[0])).to be_truthy
    end
  end

  describe 'trim_text' do
    it 'raises an exception given a nil input' do
      #      binding.pry
      expect { normalizer.trim_text(nil) }.to raise_error(NoMethodError)
    end

    context 'given a tree that contains no text' do
      let(:no_text_doc) do
        '<root_node><child1 att="val"><child_2></child_2><child3/></child1>' \
        '<child4><child5 att="abc"><child_6/></child5></child4></root_node>'
      end

      let(:original) do
        '<root_node><child1 att="val"><child_2></child_2><child3/></child1>' \
        '<child4><child5 att="abc"><child_6/></child5></child4></root_node>'
      end

      it 'returns the tree unchanged' do
        no_text_xml = Nokogiri::XML(no_text_doc)
        normalizer.trim_text(no_text_xml.root)
        expect(no_text_xml).to be_equivalent_to(original)
      end
    end

    context 'with whitespace' do
      let(:no_text_doc) do
        '<root_node><child1 att="val"><child_2>  TEXTING  </child_2><child3/></child1>' \
        '<child4><child5 att="abc"><child_6/></child5></child4></root_node>'
      end

      let(:correct_doc) do
        '<root_node><child1 att="val"><child_2>TEXTING</child_2><child3/></child1>' \
        '<child4><child5 att="abc"><child_6/></child5></child4></root_node>'
      end

      it 'correctly removes it' do
        no_text_xml = Nokogiri::XML(no_text_doc)
        normalizer.trim_text(no_text_xml.root)
        expect(no_text_xml).to be_equivalent_to(correct_doc)
      end
    end
  end

  describe 'remove_empty_attributes' do
    it 'raises an error given a null argument' do
      expect { normalizer.remove_empty_attributes(nil) }.to raise_error(NoMethodError)
    end

    context 'for a single node' do
      let(:no_attributes_doc) do
        '<root_node><child_1_1/><child_1_2 at1="forward" at2="">Some text</child_1_2>' \
        '<child_1_3 bt1="    " bt2="forgery" bt3=""></child_1_3></root_node>'
      end

      let(:correct_attributes_doc) do
        '<root_node><child_1_1/><child_1_2 at1="forward"  at2="">Some text</child_1_2><child_1_3 bt2="forgery" ></child_1_3></root_node>'
      end

      it 'removes all empty attributes for a single node' do
        no_attributes_xml = Nokogiri::XML(no_attributes_doc)
        normalizer.remove_empty_attributes(no_attributes_xml.root.children[2])
        expect(no_attributes_xml).to be_equivalent_to(correct_attributes_doc)
      end
    end

    context 'for a node that has only empty attributes' do
      let(:no_attributes_doc) do
        '<root_node><child_1_1/><child_1_2 at1="" at2="" bfk="     " r2d2="        ">Some text</child_1_2></root_node>'
      end

      let(:correct_attributes_doc) do
        '<root_node><child_1_1/><child_1_2>Some text</child_1_2></root_node>'
      end

      it 'removes all attributes' do
        no_attributes_xml = Nokogiri::XML(no_attributes_doc)
        normalizer.remove_empty_attributes(no_attributes_xml.root.children[1])
        expect(no_attributes_xml).to be_equivalent_to(correct_attributes_doc)
      end
    end
  end

  describe 'remove_empty_nodes' do
    it 'raises an exception given a null input' do
      expect { normalizer.remove_empty_nodes(nil) }.to raise_error(NoMethodError)
    end

    it 'removes all nodes, given a subtree that contains only empty nodes' do
      messy_doc = Nokogiri::XML('<root><child1>TCT</child1><child11/><child12><child21/><child22/><child23></child23></child12></root>')
      clean_doc = Nokogiri::XML('<root><child1>TCT</child1><child11/></root>')
      normalizer.remove_empty_nodes(messy_doc.root.children[2])
      expect(messy_doc).to be_equivalent_to(clean_doc)
    end

    context 'when a subtree contains a mix of empty and non-empty nodes' do
      let(:mixed_doc) do
        '<root><child_1 sf="one"> TCT  </child1><child1_1>,DOS<child1_2><child2_1/>' \
        '<child2_2/><child2_3 bf=""></child2_3></child1_2></child1_1></root>'
      end

      let(:clean_doc) do
        '<root><child_1 sf="one"> TCT  </child1><child1_1>,DOS</child1_1></root>'
      end

      it 'removes empty nodes' do
        mixed_xml = Nokogiri::XML(mixed_doc)
        normalizer.remove_empty_nodes(mixed_xml.root)
        expect(mixed_xml).to be_equivalent_to(clean_doc)
      end
    end
  end

  describe 'clean_linefeeds' do
    it 'returns the given XML unchanged if there are no linefeed characters' do
      start_doc = Nokogiri::XML('<tableOfContents> Some text that does not have any linefeed chars.  </tableOfContents>')
      final_doc = Nokogiri::XML('<tableOfContents> Some text that does not have any linefeed chars.  </tableOfContents>')
      normalizer.clean_linefeeds(start_doc.root)
      expect(start_doc).to be_equivalent_to(final_doc)
    end

    it 'returns the given XML node unchanged if it is not in the set { <tableOfContents>, <abstract>, <note> }' do
      start_doc = Nokogiri::XML('<root> Some text that does not have any linefeed chars.  </root>')
      final_doc = Nokogiri::XML('<root> Some text that does not have any linefeed chars.  </root>')
      normalizer.clean_linefeeds(start_doc.root)
      expect(start_doc).to be_equivalent_to(final_doc)
    end

    context 'when the doc contains <br>' do
      let(:start_doc) do
        '<note> How to present text: <br>Four chances.<p>Executive orders from tall managerial summits.</p> <br/>Exonerate...</note>'
      end

      let(:final_doc) do
        '<note> How to present text: &#10;Four chances.&#10;&#10;Executive orders from tall managerial summits. &#10;Exonerate...</note>'
      end

      it 'replaces <br> by &#10; and <p> by &#10;&#10;' do
        start_xml = Nokogiri::XML(start_doc)
        normalizer.clean_linefeeds(start_xml.root.xpath(described_class::LINEFEED_XPATH))
        expect(start_xml).to be_equivalent_to(final_doc)
      end
    end

    it "replaces both \n and \r by &#10; and replaces \r\n by &#10;" do
      start_doc = Nokogiri::XML("<abstract>  Newsworthy dog:\n Bark. Adium \r\n Aquamacs \r\n Firefox \r Terminal</abstract>")
      final_doc = Nokogiri::XML('<abstract>  Newsworthy dog:&#10; Bark. Adium &#10; Aquamacs &#10; Firefox &#10; Terminal</abstract>')
      normalizer.clean_linefeeds(start_doc.root)
      expect(start_doc).to be_equivalent_to(final_doc)
    end

    it 'raises an exception given a null input' do
      expect { normalizer.clean_linefeeds(nil) }.to raise_error(NoMethodError)
    end
  end
end
