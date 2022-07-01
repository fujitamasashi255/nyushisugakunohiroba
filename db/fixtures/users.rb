# frozen_string_literal: true

User.seed(:email) do |s|
  s.name = "管理人"
  s.email = "admin@nyushisugakunohiroba.jp"
  s.password  = "password1234"
  s.password  = "password1234"
  s.role = :admin
end

User.seed(:email) do |s|
  s.name = "ゲスト"
  s.email = "guest@nyushisugakunohiroba.jp"
  s.password  = "password1234"
  s.password  = "password1234"
  s.role = :guest
end
