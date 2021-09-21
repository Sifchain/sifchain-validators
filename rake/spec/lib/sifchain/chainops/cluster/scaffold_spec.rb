describe Sifchain::Chainops::Cluster::Scaffold do
  Given(:cluster_name) { Faker::Internet.domain_name }
  Given(:provider) { 'aws' }
  Given(:cwd) { '/tmp' }
  Given(:klass) { Sifchain::Chainops::Cluster::Scaffold.new(args: { cluster: cluster_name, provider: provider }, cwd: cwd) }
  Given(:cluster_tpl) { "terraform/template/#{provider}/cluster.tf.tpl" }
  Given(:envrc_tpl) { "terraform/template/#{provider}/.envrc.tpl" }

  context :templates do
    Given(:expected_result) { { 'main.tf' => "#{cwd}/../#{cluster_tpl}", '.envrc' => "#{cwd}/../#{envrc_tpl}" } }

    When(:templates) { klass.send(:templates) }

    Then { expect(templates).to eq expected_result }
  end

  context :parse_template do
    context :cluster do
      When(:file) { "#{File.dirname(__FILE__)}/../../../../fixtures/#{cluster_tpl}" }
      When(:parsed_template) { klass.send(:parse_template, file) }

      Then { expect(:parsed_template).to be_truthy }
    end

    context :envrc do
      When(:file) { "#{File.dirname(__FILE__)}/../../../../fixtures/#{envrc_tpl}" }
      When(:parsed_template) { klass.send(:parse_template, file) }

      Then { expect(:parsed_template).to be_truthy }
    end
  end

  context :save_template do
    context :cluster do
      Given(:save_to) { '/tmp/cluster.tf.tpl' }
      When(:file) { "#{File.dirname(__FILE__)}/../../../../fixtures/#{cluster_tpl}" }
      Given(:parsed_template) { klass.send(:parse_template, file) }
      Given do
        allow(File).to receive(:open).with(save_to, 'w').and_return(true)
      end

      When(:saved_template) { klass.send(:save_template, save_to, parsed_template) }

      Then { expect(saved_template).to be_truthy }
    end

    context :envrc do
      Given(:save_to) { '/tmp/.envrc' }
      When(:file) { "#{File.dirname(__FILE__)}/../../../../fixtures/#{envrc_tpl}" }
      Given(:parsed_template) { klass.send(:parse_template, file) }
      Given do
        allow(File).to receive(:open).with(save_to, 'w').and_return(true)
      end

      When(:saved_template) { klass.send(:save_template, save_to, parsed_template) }

      Then { expect(saved_template).to be_truthy }
    end
  end
end
