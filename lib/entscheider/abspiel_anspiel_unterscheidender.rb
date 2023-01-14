# frozen_string_literal: true

# Gemeinsames Modul für Entscheider, die anspielen und abspielen unterschiedlich behandeln.
module AbspielAnspielUnterscheidender
  def abspielen(stich, waehlbare_karten)
    raise NotImplementedError
  end

  def anspielen(waehlbare_karten)
    raise NotImplementedError
  end

  def waehle_karte(stich, waehlbare_karten)
    # Wenn man eh nur eine Karte spielen kann, dann spielt man die.
    return waehlbare_karten.first if waehlbare_karten.length == 1

    stich.empty? ? anspielen(waehlbare_karten) : abspielen(stich, waehlbare_karten)
  end
end
