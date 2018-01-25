# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository::Mixin::Update, type: :repository do

    describe '#update' do
      let(:incluing_class) do
        Class.new do
          include Atlas::Repository::BaseMongoidRepository::Mixin::Update
        end
      end
  
      let(:instance) { incluing_class.new }
  
      subject { instance.update(params) }
  
      let(:params) { {} }
      let(:entity) { double(:entity) }
      let(:result) { double(:result) }
      let(:partial_entity) { double(:partial_entity) }
  
      before do
        allow(instance).to receive(:wrap).and_yield
        allow(instance).to receive(:entity).and_return(entity)
        allow(entity).to receive(:new).and_return(partial_entity)
        allow(partial_entity).to receive(:identifier)
        allow(instance).to receive(:model).and_return(instance)
        allow(instance).to receive(:find).and_return(result)
      end
  
      it 'applies statements' do
        expect(result).to receive(:update_attributes)
        subject
      end
    end
  end
  