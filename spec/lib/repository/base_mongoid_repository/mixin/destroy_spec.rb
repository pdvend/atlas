# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository::Mixin::Destroy, type: :repository do

    describe '#update' do
      let(:incluing_class) do
        Class.new do
          include Atlas::Repository::BaseMongoidRepository::Mixin::Destroy
        end
      end
  
      let(:instance) { incluing_class.new }
  
      subject { instance.destroy(params) }
  
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
        expect(result).to receive(:destroy)
        subject
      end
    end
  end
  