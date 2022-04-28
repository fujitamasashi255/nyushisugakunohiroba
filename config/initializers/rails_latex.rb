# frozen_string_literal: true

LatexToPdf.config[:command] = Rails.root.join("lib/tasks/platex_dvipdfmx.sh")
