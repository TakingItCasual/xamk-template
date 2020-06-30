% Unofficial LaTeX class file for XAMK assignments/theses/reports/etc.
% This file is not meant to be modified, see xamk-template.tex instead
% If you have issues/suggestions, see github.com/TakingItCasual/xamk-template
% For comments with a number in parentheses, append the number to "tex.stackexchange.com/a/"

% TODO: Create proper formatting for bibliography

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{xamk}[2020/06/30 TakingItCasual's XAMK assignment/thesis template]

\DeclareOption{lessxamk}{\def\@lessxamkflag{}} % Do not use the official XAMK layout
\DeclareOption{minted}{\def\@reqmintedflag{}} % Require the minted package
\DeclareOption{listings}{\def\@reqlistingsflag{}} % Require the listing package
\DeclareOption{pgfplots}{\def\@reqpgfplotsflag{}} % Require the pgfplots package
\DeclareOption{bib}{\def\@reqbiblatexflag{}} % Set up biblatex with biber
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\def\@@ptsize{12pt}
\LoadClass[a4paper, \@@ptsize]{article}

\RequirePackage{etoolbox} % Needed for logic in this class file
\RequirePackage{pgfkeys} % Needed for named command options
\RequirePackage{xcolor} % Needed for background color behind code blocks
\RequirePackage[mono]{inconsolata} % Better tt font (must be loaded before text encoding)
    % Inconsolata doesn't have italics, refer italics/slanted requests to normal font (224262)
    \@namedef{T1/zi4/m/it}{<->ssub*zi4/m/n}
    \@namedef{T1/zi4/b/it}{<->ssub*zi4/b/n}
    \@namedef{T1/zi4/bx/it}{<->ssub*zi4/b/n}
    \@namedef{T1/zi4/m/sl}{<->ssub*zi4/m/n}
    \@namedef{T1/zi4/b/sl}{<->ssub*zi4/b/n}
    \@namedef{T1/zi4/bx/sl}{<->ssub*zi4/b/n}
    \@namedef{TS1/zi4/m/it}{<->ssub*zi4/m/n}
    \@namedef{TS1/zi4/b/it}{<->ssub*zi4/b/n}
    \@namedef{TS1/zi4/bx/it}{<->ssub*zi4/b/n}
    \@namedef{TS1/zi4/m/sl}{<->ssub*zi4/m/n}
    \@namedef{TS1/zi4/b/sl}{<->ssub*zi4/b/n}
    \@namedef{TS1/zi4/bx/sl}{<->ssub*zi4/b/n}
\RequirePackage{xpatch} % Needed for more advanced modifications of existing commands
\RequirePackage[immediate]{silence} % Needed to silence some unavoidable warnings

% Package options to use if the official layout is used
\ifundef{\@lessxamkflag}{
    \PassOptionsToPackage{font={small, singlespacing}, labelsep=period, listformat=empty%
        }{caption}
    \PassOptionsToPackage{skip=1.5pc}{parskip} % Increase spacing between paragraphs
    \ifdef{\@reqbiblatexflag}{%
        \PassOptionsToPackage{citestyle=authoryear}{biblatex}}{}
}{% Package options to use if the official layout is not used
    \PassOptionsToPackage{title}{appendix} % Prepends "Appendix #" to appendix sections
    \ifdef{\@reqbiblatexflag}{%
        \PassOptionsToPackage{citestyle=numeric}{biblatex}}{}
}

% minted depends on Python's Pygments package, so its usage has been made optional
\ifdef{\@reqmintedflag}{
    \RequirePackage{currfile-abspath} % Apparently only works reliably with TeX Live? (548869)
        \getabspath{\jobname.log}
        \ifdefstrequal{\theabsdir}{\thepwd}% Detect changed output dir and pass to minted
            {}{\PassOptionsToPackage{outputdir=\theabsdir}{minted}}
    \RequirePackage[cache=false% Needed to prevent errors in TeXstudio
        ]{minted} % Needed for code blocks with syntax highlighting
    % The "code" TCBListing environment is declared after tcolorbox is loaded
    \PassOptionsToPackage{minted}{tcolorbox}
    
    % Disable syntax error highlighting, since it gives false positives
    \def\@disablefcolorbox{\renewcommand\fcolorbox[4][]{##4}}
    \AtBeginEnvironment{minted}{\@disablefcolorbox}
    \xpatchcmd{\inputminted}{\minted@fvset}{\minted@fvset\@disablefcolorbox}{}{}
    \xpatchcmd{\mintinline}{\minted@fvset}{\minted@fvset\@disablefcolorbox}{}{}
}{}

\ifdef{\@reqlistingsflag}{
    \RequirePackage{listings} % Useful for command-line snippets, less baggage than minted
    % The "cmd" TCBListing environment is declared after tcolorbox is loaded
    \PassOptionsToPackage{listings}{tcolorbox}

    \lstset{
        basicstyle=\ttfamily,% Used to properly apply inconsolata
        breaklines=true,% Breaks lines rather than running off the page
        postbreak=\mbox{\textcolor{red}{$\hookrightarrow$}\space}}% Similar to minted's
}{}

% pgfplots is quite a large package (slows compilation), so its usage has been made optional
\ifdef{\@reqpgfplotsflag}{
    \RequirePackage{pgfplots} % Needed for fancy graphs
    	\pgfplotsset{compat=newest} % (139695)

    % Set default options for pgfplots graphs (most are related to the grid).
    \pgfplotsset{
        xlabel style={align=center},
        ylabel style={align=center},
        axis lines=left,
        grid=both,
        major grid style={line width=0.2pt, draw=gray!50},
        grid style={line width=0.1pt, draw=gray!10},
        minor tick num=4}
}{}

\RequirePackage[UKenglish]{babel} % Ensures consistent output regardless of system locale
\RequirePackage[T1]{fontenc} % Fixes problems related to using special/accented characters
\RequirePackage[utf8]{inputenc} % Allows for Unicode characters
\RequirePackage[
	left=1.5cm, right=1.5cm, top=2.0cm, bottom=2.0cm
	]{geometry} % Set page margins
\RequirePackage{tikz} % Needed for drawing shapes
    \usetikzlibrary{backgrounds}
\RequirePackage[fleqn]{amsmath} % Needed for math equations/formulas
    \patchcmd{\env@matrix}% Default to right-aligning matrices
        {\array{*\c@MaxMatrixCols c}}%
        {\array{*\c@MaxMatrixCols r}}{}{}
\RequirePackage{mathtools} % Needed for abs/norm commands (43009)
    \DeclarePairedDelimiter\abs{\lvert}{\rvert}
        \let\@oldabs\abs
        \def\abs{\@ifstar{\@oldabs}{\@oldabs*}} % Make starred version default
    \DeclarePairedDelimiter\norm{\lVert}{\rVert}
        \let\@oldnorm\norm
        \def\norm{\@ifstar{\@oldnorm}{\@oldnorm*}} % Make starred version default
\RequirePackage{siunitx} % Makes dealing with SI units easier, adds some number formatting
% TODO: Default float placement of H for figures and tables?
\RequirePackage{float} % Needed for "proper" figure placement
\RequirePackage[
    justification=raggedright,% Disable caption justification
    singlelinecheck=false% Disable automatic centering when caption fits on 1 line
    ]{caption} % Needed for formatting captions
\RequirePackage{setspace} % Needed for setting line spacing
\RequirePackage{tabularx} % Needed for horizontal table stretching
\RequirePackage[many, breakable]{tcolorbox} % Needed for abstract page and cmd/code boxes
    \tcbset{
        colback=blue!5!white,% Set background to light blue
        sharp corners,% XAMK is all about those sharp edges, judging from its logo
        left=0pc,right=0pc,% Left padding removed so line numbers show properly
        breakable,enhanced jigsaw}% Properly break across pages
\RequirePackage{csquotes} % Recommended for use with biblatex
\RequirePackage[titletoc]{appendix} % Prepends "Appendix #" to appendix sections in ToC
    \pretocmd{\appendix}{\ClassError{xamk}%
        {appendix command not supported, use appendices environment instead}{}}{}{}
\RequirePackage[titles]{tocloft} % Needed for ToC, LoF, and LoT formatting
\RequirePackage{parskip} % Needed for vertical spacing (must be loaded after tocloft)
\RequirePackage{atenddvi} % Needed for getting true last page? (Used for appendix page #s)
\RequirePackage[user]{zref} % Needed for more flexible labels (Used for appendix page #s)
\RequirePackage{embedfile} % Needed for attaching arbitrary files to the PDF
%\RequirePackage{lipsum} % Needed for filler text

% Creates the minted "code" environment using tcolorbox
\ifdef{\@reqmintedflag}{
    \DeclareTCBListing{code}{O{} m! O{}}{% 1st optional, 2nd mandatory, 3rd optional
        top=0pc,bottom=0pc,% Corners are sharp, so extra padding is unnecessary
        listing only,% Disable the secondary code display
        listing engine=minted,% Use minted for syntax hightlighting
        minted language=#2,
        minted options={
            baselinestretch=1.2,% Sets line spacing to 1.2
            fontsize=\small,
            linenos,% Enable line numbering
            breaklines,% Breaks lines rather than running off the page
            autogobble,% Removes common leading whitespace
            #1},
        #3}
}{}
% Creates the listings "cmd" environment using tcolorbox
\ifdef{\@reqlistingsflag}{
    \DeclareTCBListing{cmd}{O{}}{
        top=-0.5pc,bottom=-0.5pc,% Padding works differently for this, for some reason
        listing only,% Not available without minted/listings (don't put into tcbset)
        listing engine=listings,
        listing options={% Inherits from listings' lstset command
            basicstyle=\small\ttfamily,% Use small font, and properly apply inconsolata
            lineskip=0.2pc},% Sets line spacing to 1.2 (same as code env's)
        #1}
}{}

% Commands to print LoF/LoT, clear page before, and add to ToC (48511)
\newcommand*\newtoclof{%
    \cleardoublepage%
    \phantomsection\addcontentsline{toc}{section}{\listfigurename}%
    \listoffigures}
\newcommand*\newtoclot{%
    \cleardoublepage
    \phantomsection\addcontentsline{toc}{section}{\listtablename}
    \listoftables}{}

% filecontents can't be put under anything (44467)
\begingroup\newif\ifbibincluded
\ifdef{\@reqbiblatexflag}{\bibincludedtrue}{}
\ifbibincluded
\WarningFilter[temp-file]{latex}{Writing or overwriting file}
% Add doctype and lastmoddate bibliography database fields (244144)
\begin{filecontents}[overwrite]{xamkbibdm.dbx}
\DeclareDatamodelFields[type=field, datatype=literal]{doctype}
\DeclareDatamodelFields[type=field, datatype=datepart]{
    lastmodyear,
    lastmodmonth,
    lastmodday,
    lastmodhour,
    lastmodminute,
    lastmodsecond,
    lastmodtimezone,
    lastmodseason,
}
\DeclareDatamodelFields[type=field, datatype=date, skipout]{lastmoddate}
\DeclareDatamodelEntryfields{doctype, lastmoddate}
\end{filecontents}
\DeactivateWarningFilters[temp-file]
\fi\endgroup

% biblatex complains if no .bib resources are given, so its usage has been made optional
\ifdef{\@reqbiblatexflag}{
    \RequirePackage[
        datamodel=xamkbibdm,% Load entry/field definitions from xamkbibdm.dbx file
        backend=biber,
        bibstyle=authoryear,
        dashed=false,% Don't use dashes for duplicate author-years(?)
        uniquename=init,% Needed so the following option doesn't give a warning
        giveninits=true,% Abbreviate names (except for last name)
        urldate=long,% Output urldate field in natural text format
        dateabbrev=false,% Use full month names instead of abbreviations
        defernumbers=true
        ]{biblatex} % Handles the bibliography and citations

    % Combine numeric and authoryear bibstyles when lessxamk is used
    \ifdef{\@lessxamkflag}{\input{numeric.bbx}}{}

    \setlength\bibitemsep{0.6pc} % Add space between bibliography entries
    \setlength\bibhang{0pc} % Remove indent from bibliography

    % Create/modify bibliography string constants
    \NewBibliographyString{wwwdoc, lastmodstr, urlpre}
    \DefineBibliographyStrings{UKenglish}{%
        nodate = {No date},
        urlseen = {Accessed},
        wwwdoc = {WWW document},
        lastmodstr = {Updated},
        urlpre = {Available at}
    }

    % general:    github.com/plk/biblatex/blob/master/tex/latex/biblatex/biblatex.def
    % authoryear: github.com/plk/biblatex/blob/master/tex/latex/biblatex/cbx/authoryear.cbx
    % Biblatex bibliography/citation format modifications
    \renewrobustcmd*{\mkbibemph}{} % Disable all bib italics (e.g. for titles) (296150)
        \protected\long\def\blx@imc@mkbibemph#1{#1} % Also disable internal macro
    \renewrobustcmd*{\mkbibacro}{} % Disable text monospacing (e.g. for ISBN/DOI/etc.)
    \DeclareNameAlias{sortname}{family-given} % Make last names come before first names
    \DeclareDelimFormat{finalnamedelim}{%
        \ifnumgreater{\value{liststop}}{2}{\finalandcomma}{}% Preserves Oxford Comma option
        \addspace\&\space}% Redefine (based on original) to use "&" instead of "and" (549872)
    \DefineBibliographyExtras{UKenglish}{\def\finalandcomma{\addcomma}} % Enable Oxford Comma
    \DeclareFieldFormat{titlecase}{\MakeSentenceCase{#1}} % Make titles lowercase
    \DeclareFieldFormat{editortype}{\mkbibparens{#1}\nopunct}
    \xpatchbibmacro{bbx:editor}{\addcomma\space}{\space}{}{} % Remove comma
    \DeclareLabeldate{% Remove urldate as fallback date in bibliography (525164)
        \field{date}\field{year}\field{eventdate}\field{origdate}\literal{nodate}}
    \xpatchbibmacro{date+extradate}% Remove date's parentheses, add period before (428193)
        {\printtext[parens]}%
        {\setunit*{\addperiod\addspace}\printtext}{}{}
    \DeclareFieldFormat{lastmoddate}{\bibstring{lastmodstr}\addspace#1}
    \DeclareFieldFormat{url}{\bibstring{urlpre}\addcolon\addspace\url{#1}}
    \DeclareFieldFormat{pages}{#1} % Remove "pp. " prefix from pages in bibliography
    \DeclareFieldFormat{postnote}{#1} % Remove "pp. " prefix from pages in citation postnotes
    \ifdef{\@lessxamkflag}{}{% Automatic page numbers for numeric citations is confusing
        \xpatchbibmacro{postnote}% Default citation postnote to pages (TODO: multipostnote?)
            {{}}% Only replace if postnote not set by user
            {{\iffieldundef{pages}{}%
                {\setunit{\printdelim{postnotedelim}}\printfield{pages}}}}{}{}
        \xpatchbibmacro{textcite:postnote}% authoryear's textcite has its own postnote
            {\ifbool{cbx:parens}
                {\bibcloseparen}
                {}}% This search-and-replace only works without the % symbols
            {\iffieldundef{pages}%
                {\ifbool{cbx:parens}{\bibcloseparen}{}}%
                {\ifbool{cbx:parens}%
                    {\setunit{\printdelim{postnotedelim}}}%
                    {\setunit{\printdelim{extpostnotedelim}\bibopenparen}}%
                    \printfield{pages}\bibcloseparen}}{}{}}
    \DeclareFieldFormat{urldate}{\mkbibbrackets{\bibstring{urlseen}\addspace#1}}
    \DeclareFieldFormat[article,inbook,incollection,inproceedings,patent,thesis,unpublished%
        ]{title}{#1} % Remove title quotes from bibliography (94090)
    \DeclareFieldFormat[article,inbook,incollection,inproceedings,patent,thesis,unpublished%
        ]{citetitle}{#1} % Remove title quotes from citations (94090)
    % TODO: Also apply to doi/eprint?
    \xpretobibmacro{url+urldate}{% Print doctype and lastmoddate before url+urldate
        {\iffieldundef{url}{}% If doctype not specified, default to wwwdoc string
            {\iffieldundef{doctype}{\bibstring{wwwdoc}}{\printfield{doctype}}%
            \setunit*{\addperiod\addspace}}}%
        \iffieldundef{lastmodyear}{}% (244144)
            {\printlastmoddate\setunit*{\addperiod\addspace}}}{}{}

    \DeclarePrintbibliographyDefaults{heading=bibintoc} % Add bibliography to ToC
    % Citations in figures/tables put into one of these categories
    \DeclareBibliographyCategory{fullcitedfig}
    \DeclareBibliographyCategory{fullcitedtab}
    \defbibfilter{notfullcited}{
        not category=fullcitedfig and
        not category=fullcitedtab
    }
    
    \AfterEndPreamble{% Needed because something's modifying these commands later on...
        \let\@oldcaption\caption% TODO: Find more direct way to disable direct usage
        \let\@oldlabel\label}
    \newcommand*\@disablecaptioncmds[1]{%
        \pretocmd{\caption}{\ClassError{xamk}%
            {caption command not supported in #1 environment, %
            use citecaption or labelcaption instead}{}}{}{}%
        \pretocmd{\label}{\ClassError{xamk}%
            {label command not supported in #1 environment, %
            use citecaption or labelcaption instead}{}}{}{}}
    % TODO: Figure out how to handle punctuation at end of caption
    % Commands to set caption with citation and label, and prepare bibentry for LoF/LoT
    \newcommand\@makecaptioncmds[3]{%
        \@disablecaptioncmds{#1}%
        \newcommand\citecaption[2]{%
            \ifundef{\@lessxamkflag}%
                {\@oldcaption[#3 {##2}. \protect\fullcite{##1}]{{##2} \protect\parencite{##1}}}%
                {\@oldcaption{{##2} \protect\parencite{##1}}}%
            \@oldlabel{#2:##1}%
            \addtocategory{fullcited#2}{##1}}%
        \newcommand\labelcaption[2]{%
            \ifundef{\@lessxamkflag}%
                {\@oldcaption[#3 {##2}.]{{##2}}}%
                {\@oldcaption{{##2}}}%
            \@oldlabel{#2:##1}}}
    \AtBeginEnvironment{figure}{%
        \@makecaptioncmds{figure}{fig}{\figurename\ \thefigure.}}
    \AtBeginEnvironment{table}{%
        \@makecaptioncmds{table}{tab}{\tablename\ \thetable.}}

    % Set options for \makebibliography command to show list of figures/tables
    \pgfkeys{
        /makebibliography/.is family, /makebibliography,
        lof/.default = true,% lof's value if "lof" option given to command (without value)
        lof/.initial = false,% lof's value if "lof" option not given to command
        lot/.default = true,
        lot/.initial = false,
    }
    % Command to render bibliography (and optionally LoF/LoT) to own page(s)
    \newcommand\makebibliography[1][]{
        \pgfkeys{/makebibliography, #1}
        \newbool{showlof}\setbool{showlof}{\pgfkeysvalueof{/makebibliography/lof}}
        \newbool{showlot}\setbool{showlot}{\pgfkeysvalueof{/makebibliography/lot}}

        \begin{singlespace}
        \clearpage
        \ifdef{\@lessxamkflag}{\printbibliography}{%
            % If all references in LoF/LoT, suppress warning (TODO: check if empty before)
            \WarningFilter[temp-empty-bib]{latex}{Empty bibliography}%
            \ifbool{showlof}% References left out of bibliography if in LoF or LoT
                {\ifbool{showlot}%
                    {\printbibliography[filter=notfullcited]}%
                    {\printbibliography[notcategory=fullcitedfig]}}%
                {\ifbool{showlot}%
                    {\printbibliography[notcategory=fullcitedtab]}%
                    {\printbibliography}}%
            \DeactivateWarningFilters[temp-empty-bib]}

        \ifbool{showlof}{\newtoclof}{}
        \ifbool{showlot}{\newtoclot}{}
        \end{singlespace}

        \clearpage
    }

    % Make bibliography entries visible even if uncited
    \AfterEndPreamble{\nocite{*}}
}{}

\RequirePackage[
    hidelinks,% Remove annoying borders
    colorlinks=true,% Re-enable colors disabled by hidelinks
    urlcolor=blue,
    linkcolor=black,
    citecolor=black
    ]{hyperref} % Needed for urls/hyperlinks/etc. (must be loaded after biblatex)

% Official XAMK page margins.
\newcommand*\@xamkpagegeometry{%
    \newgeometry{left=4.3cm, right=2.0cm, top=2.25cm, bottom=1.25cm,%
        headheight=14.5pt}}
% Custom page margins for the title page.
\newcommand*\@titlepagegeometry{%
    \newgeometry{left=3.0cm, right=3.0cm, top=3.0cm, bottom=3.0cm}}
% Custom page margins for thesis abstract
\newcommand*\@thesisabstractgeometry{%
    \newgeometry{left=1.5cm, right=1.5cm, top=1.5cm, bottom=1.5cm}}
% Custom page margins for the table of contents
\newcommand*\@tableofcontentsgeometry{%
    \newgeometry{left=1.75cm, right=1.75cm, top=1.75cm, bottom=1.75cm}}
% Custom page margins for appendices (large headheight to allow for header)
\newcommand*\@xamkappendixgeometry{%
    \newgeometry{left=4.3cm, right=2.0cm, top=2.25cm, bottom=1.25cm,%
        headheight=42.0pt, headsep=0pt}}

% Official section/ToC formatting
\newcommand*\@xamktoclayout{
    \WarningFilter[temp-sectsty]{latex}{Command} % (311003)
    \RequirePackage{sectsty} % Needed for formatting table of contents
    \DeactivateWarningFilters[temp-sectsty]
        \let\SS@makeulinesect\relax
        \let\SS@makeulinepartchap\relax
    % Makes section headings all caps, and make font size same as paragraphs
    \allsectionsfont{\fontsize{\@@ptsize}{\@@ptsize}\selectfont}
    \sectionfont{\fontsize{\@@ptsize}{\@@ptsize}\selectfont\scshape\MakeUppercase}

    \renewcommand{\cftdotsep}{2} % Make dots in ToC/LoF/LoT closer together
    \renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}} % Add dotted line to sections in ToC
    % Remove bold font weight from sections in ToC
    \renewcommand{\cftsecfont}{}
    \renewcommand{\cftsecpagefont}{}

    % Make sections within ToC uppercase (156917)
    \let\@oldcontentsline\contentsline
    \def\contentsline##1##2{%
        \expandafter\ifx\csname l@##1\endcsname\l@section
            \expandafter\@firstoftwo
        \else
            \expandafter\@secondoftwo
        \fi
        {\@oldcontentsline{##1}{\MakeUppercase{##2}}}%
        {\@oldcontentsline{##1}{##2}}%
    }

    % Make appendices use numbers instead of letters
    \let\@oldappendices\appendices
    \def\appendices{\@oldappendices\renewcommand{\thesection}{\arabic{section}}}

    % Redefine \tableofcontents to add custom geometry and line spacing
    \let\@@oldtableofcontents\tableofcontents
    \renewcommand\tableofcontents{
        \@tableofcontentsgeometry

        \begin{onehalfspace}
        \@@oldtableofcontents
        \end{onehalfspace}

        \restoregeometry
    }
}

\setlength{\cftbeforefigskip}{0.6pc} % Add space between LoF entries
\setlength{\cftbeforetabskip}{0.6pc} % Add space between LoT entries
% Official list of figures/tables formatting (fig/tab numbers >999 will clip caption)
\newcommand*\@xamkloftlayout{
    \renewcommand{\@tocrmarg}{2.5pc plus1fil} % Set ToC/LoF/LoT entries to ragged-right (62006)
    % Remove LoF/LoT indents
    \cftsetindents{figure}{0pc}{0pc}
    \cftsetindents{table}{0pc}{0pc}
}

% Official appendix formatting
\newcommand*\@xamkapplayout{
    \AtBeginEnvironment{appendices}{
        \pretocmd{\section}{\resetpageaux}{}{} % Force appendix sections to start from new pages
        \@xamkappendixgeometry
        \singlespacing % Set line spacing to 1
        \setlength{\parskip}{1pc} % Match paragraph spacing with line spacing
        
        \chead{\thepage \\ ~\\} % Compensate for increased headheight (place higher)
        % Add "Appendix # (page # of #)" to the right header
        \rhead{Appendix \thesection\ (\appendixpagenumbers)}
        
        \renewcommand*{\@seccntformat}[1]{} % Remove section header numbers
        
        % Maintain total page count for each appendix section (82560)
        \newcounter{pageaux}
        \def\currentauxref{PAGEAUX1}
        \newcommand{\appendixpagenumbers}{%
            \stepcounter{pageaux}% Incremented by rhead every page
            page \thepageaux\ of \ref*{\currentauxref}}
        \newcommand{\resetpageaux}{%
            \clearpage
            \edef\@currentlabel{\thepageaux}\label{\currentauxref}%
            \xdef\currentauxref{PAGEAUX\thepage}%
            \setcounter{pageaux}{0}}
        \AtEndDvi{\edef\@currentlabel{\thepageaux}\label{\currentauxref}}
    }
    \AtEndEnvironment{appendices}{
        \restoregeometry
        \chead{\thepage}
        \rhead{}
    }
}

% Apply the official XAMK layout. Can be disabled with the lessxamk class option.
\ifundef{\@lessxamkflag}{
    \@xamkpagegeometry
    \RequirePackage{helvet} % Provides the helvet font
        \renewcommand*{\familydefault}{\sfdefault} % Set Helvet as default font
        \RequirePackage[helvet]{sfmath} % Set Helvet as default font for math
    \@xamktoclayout % Apply official section/ToC formatting
    \@xamkloftlayout % Apply official list of figures/tables formatting
    \@xamkapplayout % Apply official appendix formatting
    \onehalfspacing % Set line spacing to 1.5
    \RequirePackage{fancyhdr} % Allows customization of the header and footer
        \pagestyle{fancy}
        \fancyhf{} % Clear whatever defaults the header and footer may have
        \renewcommand\headrulewidth{0pc} % Remove the header bar
        \chead{\thepage} % Print page number to center of header
    \AtBeginDocument{\raggedright} % Disable text justification
}{% Commands to run if the official layout isn't used
    % Make captions include the section they're in.
    \numberwithin{equation}{section}
    \numberwithin{figure}{section}
    \numberwithin{table}{section}
}

% Removes page number(s) from ToC (works with multiple pages)
\let\@oldtableofcontents\tableofcontents
\renewcommand\tableofcontents{
    \pagestyle{empty}
    \@oldtableofcontents
    \cleardoublepage
    \ifdef{\@lessxamkflag}{\pagestyle{plain}}{\pagestyle{fancy}}
}

% Colors used in title page
\definecolor{xamklightblue}{RGB}{200, 200, 255}
\definecolor{xamkdarkblue}{RGB}{11, 124, 164}

% TikZ code for the page border used in the title page.
\newcommand*\xamkdrawpageborder{
    \coordinate[xshift=0.75cm , yshift=-0.75cm] (b1)  at (current page.north west);
    \coordinate[xshift=-0.65cm, yshift=-0.75cm] (b2)  at (current page.north);
    \coordinate[                yshift=-1.4cm ] (b3)  at (current page.north);
    \coordinate[xshift=0.65cm , yshift=-0.75cm] (b4)  at (current page.north);
    \coordinate[xshift=-0.75cm, yshift=-0.75cm] (b5)  at (current page.north east);
    \coordinate[xshift=-0.75cm, yshift=0.65cm ] (b6)  at (current page.east);
    \coordinate[xshift=-1.4cm                 ] (b7)  at (current page.east);
    \coordinate[xshift=-0.75cm, yshift=-0.65cm] (b8)  at (current page.east);
    \coordinate[xshift=-0.75cm, yshift=0.75cm ] (b9)  at (current page.south east);
    \coordinate[xshift=0.65cm , yshift=0.75cm ] (b10) at (current page.south);
    \coordinate[                yshift=1.4cm  ] (b11) at (current page.south);
    \coordinate[xshift=-0.65cm, yshift=0.75cm ] (b12) at (current page.south);
    \coordinate[xshift=0.75cm , yshift=0.75cm ] (b13) at (current page.south west);
    \coordinate[xshift=0.75cm , yshift=-0.65cm] (b14) at (current page.west);
    \coordinate[xshift=1.4cm                  ] (b15) at (current page.west);
    \coordinate[xshift=0.75cm , yshift=0.65cm ] (b16) at (current page.west);
    \draw[draw=xamklightblue, line width=8pt] (b1) -- (b2) -- (b3) -- (b4) -- (b5) -- (b6) -- (b7) -- (b8) -- (b9) -- (b10) -- (b11) -- (b12) -- (b13) -- (b14) -- (b15) -- (b16) -- cycle;
}
% TikZ code for the XAMK logo.
\newcommand*\xamkdrawlogo{
    % The fat background X
    \coordinate (l1)  at (0  , 0 );
    \coordinate (l2)  at (0  , 39);
    \coordinate (l3)  at (8  , 47);
    \coordinate (l4)  at (0  , 55);
    \coordinate (l5)  at (0  , 94);
    \coordinate (l6)  at (115, 94);
    \coordinate (l7)  at (122, 87);
    \coordinate (l8)  at (129, 94);
    \coordinate (l9)  at (244, 94);
    \coordinate (l10) at (244, 55);
    \coordinate (l11) at (236, 47);
    \coordinate (l12) at (244, 39);
    \coordinate (l13) at (244, 0 );
    \coordinate (l14) at (129, 0 );
    \coordinate (l15) at (122, 7 );
    \coordinate (l16) at (115, 0 );
    \fill[fill=xamkdarkblue] (l1) -- (l2) -- (l3) -- (l4) -- (l5) -- (l6) -- (l7) -- (l8) -- (l9) -- (l10) -- (l11) -- (l12) -- (l13) -- (l14) -- (l15) -- (l16) -- cycle;

    % The X in XAMK
    \coordinate (lx1)  at (24, 25  );
    \coordinate (lx2)  at (41, 48  );
    \coordinate (lx3)  at (24, 71  );
    \coordinate (lx4)  at (39, 71  );
    \coordinate (lx5)  at (49, 57.5);
    \coordinate (lx6)  at (59, 71  );
    \coordinate (lx7)  at (74, 71  );
    \coordinate (lx8)  at (57, 48  );
    \coordinate (lx9)  at (74, 25  );
    \coordinate (lx10) at (59, 25  );
    \coordinate (lx11) at (49, 38.5);
    \coordinate (lx12) at (39, 25  );
    % The A in XAMK
    \coordinate (la1) at (68 , 25);
    \coordinate (la2) at (103, 71);
    \coordinate (la3) at (115, 71);
    \coordinate (la4) at (115, 25);
    \coordinate (la5) at (89 , 25);
    \coordinate (la6) at (98 , 37);
    \coordinate (la7) at (102, 37);
    \coordinate (la8) at (102, 49);
    \coordinate (la9) at (83 , 25);
    % The M in XAMK
    \coordinate (lm1)  at (121  , 25);
    \coordinate (lm2)  at (121  , 71);
    \coordinate (lm3)  at (144.5, 53);
    \coordinate (lm4)  at (168  , 71);
    \coordinate (lm5)  at (168  , 25);
    \coordinate (lm6)  at (155  , 25);
    \coordinate (lm7)  at (155  , 45);
    \coordinate (lm8)  at (144.5, 36);
    \coordinate (lm9)  at (134  , 45);
    \coordinate (lm10) at (134  , 25);
    % The first part of the K in XAMK
    \coordinate (lk1_1) at (174, 25);
    \coordinate (lk1_2) at (174, 71);
    \coordinate (lk1_3) at (187, 71);
    \coordinate (lk1_4) at (187, 25);
    % The second part of the K in XAMK
    \coordinate (lk2_1) at (205, 25);
    \coordinate (lk2_2) at (187, 48);
    \coordinate (lk2_3) at (205, 71);
    \coordinate (lk2_4) at (220, 71);
    \coordinate (lk2_5) at (202, 48);
    \coordinate (lk2_6) at (220, 25);
    \fill[fill=white]
        (lx1) -- (lx2) -- (lx3) -- (lx4) -- (lx5) -- (lx6) -- (lx7) -- (lx8) -- (lx9) -- (lx10) -- (lx11) -- (lx12) -- (lx1)
        (la1) -- (la2) -- (la3) -- (la4) -- (la5) -- (la6) -- (la7) -- (la8) -- (la9) -- (la1)
        (lm1) -- (lm2) -- (lm3) -- (lm4) -- (lm5) -- (lm6) -- (lm7) -- (lm8) -- (lm9) -- (lm10) -- (lm1)
        (lk1_1) -- (lk1_2) -- (lk1_3) -- (lk1_4) -- (lk1_1)
        (lk2_1) -- (lk2_2) -- (lk2_3) -- (lk2_4) -- (lk2_5) -- (lk2_6) -- (lk2_1);
}
% Command to insert the 2 vector graphics into the title page.
\newcommand*\@titlepageimages{
	\begin{tikzpicture}[remember picture, overlay, x=1pt, y=1pt]
        \xamkdrawpageborder
	    \tikzset{align=center, shift={(current page.center)}, yshift=-216pt, xshift=-122pt}
	    \xamkdrawlogo
	    \node[text width=260pt, shift={(current page.center)}, yshift=-240pt] at (0, 0)
            {\fontseries{b}\fontfamily{phv}\selectfont\Large South-Eastern Finland};
	    \node[text width=260pt, shift={(current page.center)}, yshift=-261pt] at (0, 0)
            {\fontseries{b}\fontfamily{phv}\selectfont\Large University of Applied Sciences};
	\end{tikzpicture}
}

% Include the title page in page numbering (172005)
\renewenvironment{titlepage}{\thispagestyle{empty}}{} % Page number not printed though

\newcommand*\@placehold[1]{$\langle$#1$\rangle$} % Places < > around text

% The list of students. Defaults to "<Student Name> | <Student Number> | <Group ID>".
\def\@xamkdefaultstudent{\@placehold{Student Name} | \@placehold{Student Number} | \@placehold{Group ID}\par}
\newcommand*\xamkstudent[3]{\listadd\@xamkstudentlist{#1 | #2 | #3}}
\newcommand*\@iteratexamkstudents[1]{{#1\\}}
% The paper title. Defaults to "<Paper Title>".
\newcommand*\xamkpapertitle[1]{\def\@xamkpapertitle{#1}}
\xamkpapertitle{\@placehold{Paper Title}}
% The paper subtitle. If not set by the user, nothing will appear.
\newcommand*\xamkpapersubtitle[1]{\def\@xamkpapersubtitle{#1}}
% The paper type (assignment, report, etc.). Defaults to "<Paper Type>".
\newcommand*\xamkpapertype[1]{\def\@xamkpapertype{#1}}
\xamkpapertype{\@placehold{Paper Type}}
% The name of the course the paper was written for. Defaults to "<Course Name>".
\newcommand*\xamkcoursename[1]{\def\@xamkcoursename{#1}}
\xamkcoursename{\@placehold{Course Name}}
% The time (year/date/etc.) the paper was finished. Defaults to "<Date>".
\newcommand*\xamkpaperdate[1]{\def\@xamkpaperdate{#1}}
\xamkpaperdate{\@placehold{Date}}

% Student's name. Defaults to "<First-name Last-name>".
\newcommand*\xamkstudentname[1]{\def\@xamkstudentname{#1}}
\xamkstudentname{\@placehold{First-name Last-name}}
% The thesis type (Bachelor’s, Master’s, etc.). Defaults to "Bachelor’s Degree".
\newcommand*\xamkdegreetype[1]{\def\@xamkdegreetype{#1}}
\xamkdegreetype{Bachelor’s Degree}
% The degree programme the thesis was written for. Defaults to "<Degree Programme>".
\newcommand*\xamkdegreeprogramme[1]{\def\@xamkdegreeprogramme{#1}}
\xamkdegreeprogramme{\href{https://student.xamk.fi/studies-and-supporting-services/Documents/degree_titles.pdf}{\@placehold{Degree Programme}}}

% Set option for \maketitle command to be a thesis title page
\pgfkeys{
    /maketitle/.is family, /maketitle,
    thesis/.default = true,
    thesis/.initial = false,
}
% Command for rendering the title page
\renewcommand*\maketitle[1][]{
    \pgfkeys{/maketitle, #1}
    \newbool{thesistitle}\setbool{thesistitle}{\pgfkeysvalueof{/maketitle/thesis}}

    \@titlepagegeometry
    \begin{singlespace}
	\begin{titlepage}
		\begin{center}
		    \@titlepageimages
		{\Large\bf
		    \notbool{thesistitle}{
    			\ifdef{\@xamkstudentlist}%
    			    {\forlistloop\@iteratexamkstudents{\@xamkstudentlist}}%
    			    {\@xamkdefaultstudent}%
			}{\@xamkstudentname\par}
			\vspace*{3pc}
			{\huge\@xamkpapertitle\par}
			\ifdef{\@xamkpapersubtitle}{{\LARGE\@xamkpapersubtitle\par}}{}
			\vspace*{2pc}
			\notbool{thesistitle}{%
    			\@xamkpapertype\par
    			\@xamkcoursename\par
			}{%
    			\@xamkdegreetype\par
    			\@xamkdegreeprogramme\par
			}
			\vspace*{2pc}
			\@xamkpaperdate\par
		}
		\end{center}
	\end{titlepage}
	\end{singlespace}
	\restoregeometry
}

% Number of pages until the appendix. Defaults to "XX".
\newcommand*\xamkpagecount[1]{\def\@xamkpagecount{#1}}
\xamkpagecount{XX}
% Number of appendix pages. Defaults to "X".
\newcommand*\xamkappendixpagecount[1]{\def\@xamkappendixpagecount{#1}}
\xamkappendixpagecount{X}
% Who commissioned the thesis. Defaults to "N/A".
\newcommand*\xamkthesiscommissioner[1]{\def\@xamkthesiscommissioner{#1}}
\xamkthesiscommissioner{N/A}
% Who supervised the writing of the thesis. Defaults to "<Supervisor>".
\newcommand*\xamkthesissupervisor[1]{\def\@xamkthesissupervisor{#1}}
\xamkthesissupervisor{\@placehold{Supervisor}}
% Keywords for the thesis. Defaults to "<Keywords>".
\newcommand*\xamkthesiskeywords[1]{\def\@xamkthesiskeywords{#1}}
\xamkthesiskeywords{\@placehold{Keywords}}
% Abstract for the thesis. Expects a file name as input. Defaults to "<Thesis Abstract>".
\newcommand*\xamkthesisabstractfile[1]{\def\@xamkthesisabstractfile{#1}}

% Command for rendering the thesis abstract
\newcommand*\makethesisabstract{
    % If lessxamk, use default parskip, otherwise use 1pc (even default needs explicit setting)
    \newlength{\abstractparskip}\ifdef{\@lessxamkflag}%
        {\setlength{\abstractparskip}{\parskip}}{\setlength{\abstractparskip}{1pc}}
    % tcolorbox's [parbox=false] could also be used (154994), but that affects all rows
    \newenvironment{tcbrow}{\setlength{\parskip}{\abstractparskip}}{}
    \@thesisabstractgeometry
    \begin{singlespace}
    \thispagestyle{empty} % Don't print page number
	\begin{tikzpicture}[remember picture, overlay, x=0.33pt, y=0.33pt]
        \xamkdrawlogo
	\end{tikzpicture}
    \begin{tcolorbox}[
    enhanced, space to upper,
    height fill, sharp corners,
    segmentation style=solid,
    colback=white,% Background color
    middle=0pc,boxsep=0.5pc]% Inner margins
        \ifundef{\@lessxamkflag}{\raggedright}{}
        \noindent\begin{tabularx}{\textwidth}% 3 columns -> sum must be exactly 3
        {@{} >{\hsize=1.15\hsize}X >{\hsize=1.15\hsize}X >{\hsize=0.7\hsize}X @{}}
            \textbf{Author}
            \vspace*{0.5pc}

            \@xamkstudentname
            &
            \textbf{Degree}
            \vspace*{0.5pc}

            \@xamkdegreeprogramme
            &
            \textbf{Time}
            \vspace*{0.5pc}

            \@xamkpaperdate
        \end{tabularx}
    \tcbline
        \noindent\begin{tabularx}{\textwidth}%
        % 2 columns -> sum must be exactly 2 (enough space for up to 999 appendix pages)
        {@{} >{\hsize=1.44\hsize}X >{\hsize=0.56\hsize}X @{}}
        \textbf{Thesis title}
        \vspace*{0.5pc}

        \@xamkpapertitle
        \ifdef{\@xamkpapersubtitle}{\par\@xamkpapersubtitle}{}
        &% "s" is added after "page" if page count is anything other than "1"
        \@xamkpagecount\ page\ifdefstring{\@xamkpagecount}{1}{}{s}

        \@xamkappendixpagecount\ page\ifdefstring{\@xamkappendixpagecount}{1}{}{s} of appendices
        \end{tabularx}
    \tcbline
        \textbf{Commissioned by}
        \vspace*{0.5pc}

        \@xamkthesiscommissioner
    \tcbline
        \textbf{Supervisor}
        \vspace*{0.5pc}

        \@xamkthesissupervisor
    \tcbline
        \textbf{Abstract}

        \begin{tcbrow}
        \ifdef{\@xamkthesisabstractfile}%
            {\input{\@xamkthesisabstractfile}}%
            {\@placehold{Thesis Abstract}}
        \end{tcbrow}
    \tcblower
        \textbf{Keywords}
        \vspace*{0.5pc}

        \@xamkthesiskeywords
    \end{tcolorbox}
    \end{singlespace}
	\restoregeometry
}

\endinput