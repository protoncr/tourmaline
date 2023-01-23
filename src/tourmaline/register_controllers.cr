module Tourmaline
  module ManuallyRegisterControllersWithADI
    include Athena::DependencyInjection::PreArgumentsCompilerPass

    macro included
      macro finished
        {% verbatim do %}
          {%
            Tourmaline::Controller.all_subclasses.each do |klass|
              # Skip abstract classes
              # Skip classes already registered via the annotation
              if !klass.abstract? && !klass.annotation(ADI::Register)
                SERVICE_HASH[klass.name.gsub(/::/, "_").underscore] = {
                  visibility: Visibility::INTERNAL,
                  service:    klass,
                  ivar_type:  klass,
                  tags:       [TL::Listeners::TAG],
                  generics:   [] of Nil,
                  arguments:  [] of Nil,
                }
              end
            end
          %}
        {% end %}
      end
    end
  end
end
