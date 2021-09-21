describe Sifchain::Chainops::Sifnode::Standalone::Boot do
  Given(:chain_id) { Faker::Lorem.word }
  Given(:moniker) { Faker::Lorem.word }
  Given(:mnemonic) { 'peasant fold clean pulp federal stool sick slot range brush kitten combine crunch ask snap east answer unaware code broom wave fine sense fiscal' }
  Given(:gas_price) { '0.5rowan' }
  Given(:bind_ip_address) { Faker::Internet.ip_v4_address }
  Given(:flags) { '-d' }
  Given(:args) do
    { chain_id: chain_id, moniker: moniker, mnemonic: mnemonic, gas_price: gas_price,
      bind_ip_address: bind_ip_address, flags: flags }
  end
  Given(:cwd) { 'tmp' }
  Given(:klass) { Sifchain::Chainops::Sifnode::Standalone::Boot.new(args: args, cwd: cwd) }

  context :moniker do
    When(:result) { klass.send(:moniker) }

    Then { expect(result).to eq moniker }
  end

  context :mnemonic do
    When(:result) { klass.send(:mnemonic) }

    Then { expect(result).to eq mnemonic }
  end

  context :gas_price do
    When(:result) { klass.send(:gas_price) }

    Then { expect(result).to eq gas_price }
  end

  context :bind_ip_address do
    When(:result) { klass.send(:bind_ip_address) }

    Then { expect(result).to eq bind_ip_address }
  end

  context :docker_vars do
    Given(:expected_result) { "MONIKER=#{moniker} MNEMONIC=#{mnemonic} GAS_PRICE=#{gas_price} BIND_IP_ADDRESS=#{bind_ip_address}" }

    When(:result) { klass.send(:docker_vars) }

    Then { expect(result).to eq expected_result }
  end

  context :chain_id do
    When(:result) { klass.send(:chain_id) }

    Then { expect(result).to eq chain_id }
  end
end
