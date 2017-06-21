describe Grape::Roar::Extensions::RelationalModels::Mapper do
  let(:entity) { double }
  let(:klass)  { double }

  subject { described_class.new(entity) }

  context '#initialize' do
    it 'assigns the correct variables' do
      expect(subject.instance_variable_get(:@entity)).to eql(entity)
      expect(subject.instance_variable_get(:@config)).to eql({})
      subject
    end
  end

  context '#adapter' do
    before do
      subject.instance_variable_set(:@model_klass, Class.new(ActiveRecord::Base))
    end

    it 'should resolve the correct adapter' do
      expect(subject.adapter).to be_a(
        Grape::Roar::Extensions::RelationalModels::Adapter::ActiveRecord
      )
    end
  end

  context '#decorate' do
    let(:adapter) { double }
    let(:config) do
      { test_single: { relation_kind: :belongs_to, misc_opt: 'foo' },
        test_collection: { relation_kind: :has_many, misc_opt: 'baz' } }
    end

    let(:klass) { double }

    before do
      allow(subject).to receive(:adapter).and_return(adapter)

      allow(adapter).to receive(:collection_methods).and_return(%i(has_many))
      allow(adapter).to receive(:single_entity_methods).and_return(%i(belongs_to))
      allow(entity).to receive(:name).and_return('Foo::Bar')

      subject.instance_variable_set(:@config, config)
    end

    it 'should correctly decorate the entity' do
      expect(adapter).to receive(:belongs_to_valid?).with(
        :test_single
      ).and_return(true)

      expect(adapter).to receive(:has_many_valid?).with(
        :test_collection
      ).and_return(true)

      expect(entity).to receive(:collection).with(
        :test_collection,  relation_kind: :has_many, misc_opt: 'baz'
      )

      expect(entity).to receive(:property).with(
        :test_single,  relation_kind: :belongs_to, misc_opt: 'foo'
      )

      subject.decorate(klass)
      expect(subject.instance_variable_get(:@model_klass)).to eql(klass)
    end

    context 'with an invalid relation type' do
      let(:config) do
        { test_single: { relation_kind: :has_baz, misc_opt: 'foo' } }
      end

      it 'will raise the correct exception' do
        expect { subject.decorate(klass) }.to raise_error(
          Grape::Roar::Extensions::RelationalModels::Exceptions::UnsupportedRelationError
        )
      end
    end
  end
end