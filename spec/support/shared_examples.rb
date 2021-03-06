
shared_context 'essentials' do
  before do
    3.times.each do
      TestModel.create!
    end
  end

  it 'plucks the ids of the objects to a hash correctly' do
    TestModel.all.pluck_to_hash(:id).each do |hash|
      expect(hash.class).to eq(HashWithIndifferentAccess)
      expect(hash).to have_key(:id)
    end
  end

  it 'pluck field with lowercase alias' do
    TestModel.all.pluck_to_hash('id as something').each do |hash|
      expect(hash).to have_key(:something)
    end
  end

  it 'pluck field with uppercase alias' do
    TestModel.all.pluck_to_hash('id AS otherfield').each do |hash|
      expect(hash).to have_key(:otherfield)
    end
  end

  it 'pluck field with mixedcase alias' do
    TestModel.all.pluck_to_hash('id As anotherfield').each do |hash|
      expect(hash).to have_key(:anotherfield)
    end
  end
  it 'works with block parameter' do
    TestModel.pluck_to_hash(:id) do |hash|
      expect(hash).to have_key(:id)
    end
  end

  context 'the model does not have the attribute specified' do
    it 'raises an error' do
      expect do
        TestModel.all.pluck_to_hash(:foo)
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  context 'no models exist for the given criteria' do
    it 'returns an empty relation' do
      result = TestModel.where(id: -1).pluck_to_hash(:id)
      expect(result).to be_empty
    end
  end

  context 'specifying multiple attributes' do
    it 'returns a hash with both attributes' do
      TestModel.all.pluck_to_hash(:id, :test_attribute).each do |hash|
        expect(hash.class).to eq(HashWithIndifferentAccess)
        expect(hash).to have_key('id')
        expect(hash).to have_key(:test_attribute)
      end
    end
  end
end

shared_context 'making sure alias is fine' do
  describe '.pluck_h' do
    before do
      3.times.each do
        TestModel.create!
      end
    end

    it 'plucks the ids of the objects to a hash correctly' do
      TestModel.all.pluck_h(:id).each do |hash|
        expect(hash.class).to eq(HashWithIndifferentAccess)
        expect(hash).to have_key(:id)
      end
    end

    context 'the model does not have the attribute specified' do
      it 'raises an error' do
        expect do
          TestModel.all.pluck_h(:foo)
        end.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context 'no models exist for the given criteria' do
      it 'returns an empty relation' do
        result = TestModel.where(id: -1).pluck_h(:id)
        expect(result).to be_empty
      end
    end

    context 'specifying multiple attributes' do
      it 'returns a hash with both attributes' do
        TestModel.all.pluck_h(:id, :test_attribute).each do |hash|
          expect(hash.class).to eq(HashWithIndifferentAccess)
          expect(hash).to have_key(:id)
          expect(hash).to have_key(:test_attribute)
        end
      end
    end
  end
end
