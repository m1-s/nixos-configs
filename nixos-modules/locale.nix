{
  i18n = {
    defaultLocale = "en_US.UTF-8";

    # KDE's format picker offers en_DE, but glibc ships no such locale, so the
    # session inherits LC_* values that cannot be set and every program using
    # setlocale warns. de_DE is the glibc locale for the same German number,
    # currency and metric conventions.
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];

    extraLocaleSettings = {
      # Sort by byte value rather than by dictionary rules. Plain C does that
      # too, but its ANSI_X3.4-1968 charset makes Qt warn on every start;
      # C.UTF-8 keeps the ordering and drops the warning.
      LC_COLLATE = "C.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
    };
  };
}
