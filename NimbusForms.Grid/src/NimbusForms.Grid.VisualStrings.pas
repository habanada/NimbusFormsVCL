unit NimbusForms.Grid.VisualStrings;

interface

type
  ThemedGridVisualStrings = class sealed
  public
    const
      ErrSvgEmpty = 'The SVG document is empty.';
      ErrSvgNoRoot = 'The SVG document has no root element.';
      ErrSvgNotSvg = 'The root element is not an svg element.';
      ErrSvgMalformed = 'The SVG document is malformed.';
      ErrSvgFileNotFound = 'The SVG file was not found: %s';
      ErrActionKeyRequired = 'Action key is required.';
      SvgRootName = 'svg';
      SvgNamespaceSeparator = ':';
      SvgXlinkPrefix = 'xlink:';
      SvgHrefName = 'href';
      DefaultPaintBlack = '#000000';
      ErrIconFileNameEmpty = 'File name is empty.';
      ErrIconFileMissing = 'File does not exist: %s';
      ErrIconKeyOrSvgEmpty = 'SVG string or key is empty.';
      SvgFontSans = 'Segoe UI';
      SvgFontSerif = 'Times New Roman';
      SvgFontMono = 'Consolas';
      SvgGenericSansSerif = 'sans-serif';
      SvgGenericSerif = 'serif';
      SvgGenericMonospace = 'monospace';
      IconCacheFilePrefix = 'file|';
      IconCacheTextPrefix = 'text|';
  end;

implementation

end.
