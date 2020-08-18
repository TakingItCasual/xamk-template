% Unofficial LaTeX class file for XAMK assignments/theses/reports/etc.
% This file is not meant to be modified, see xamk-template.tex instead
% If you have issues/suggestions, see github.com/TakingItCasual/xamk-template
% For comments with a number in parentheses, append to "tex.stackexchange.com"
% Tested with Overleaf (TeX Live version 2019) and a local Win10 TeX Live 2020 installation

% TODO: Create proper formatting for bibliography
% TODO: Formatting and example for (list of) equations/symbols

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{xamk}[2020/08/18 TakingItCasual's XAMK assignment/thesis template]

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
\RequirePackage{xcolor} % Needed for background color behind code blocks
\RequirePackage[scaled=0.85]{beramono} % Better tt font (must be loaded before text encoding)
\RequirePackage{xpatch} % Needed for more advanced modifications of existing commands
\RequirePackage{xparse} % Needed for creating advanced commands, and for LaTeX3
\RequirePackage[immediate]{silence} % Needed to silence some unavoidable but harmless warnings

\ifundef{\@lessxamkflag}{% Package options to use if the official layout is used
    \PassOptionsToPackage{%
        font={footnotesize, singlespacing},% 10pt font size, single line spacing
        justification=raggedright,% Disable caption justification
        labelsep=period,% Replace ":" with "." after fig/tab number
        listformat=empty% Remove fig/tab numbering in LoF/LoT
        }{caption}
    \PassOptionsToPackage{skip=1.5pc}{parskip} % Increase spacing between paragraphs
        % Readd space under LoF/LoT section titles (/a/544983) (TODO: Remove when bug fixed)
        \addtocontents{lof}{\vspace*{1pc}} % parskip's skip - \cftbeforefigskip
        \addtocontents{lot}{\vspace*{1pc}} % parskip's skip - \cftbeforetabskip
    \ifdef{\@reqbiblatexflag}{\PassOptionsToPackage{citestyle=authoryear}{biblatex}}{}
}{% Package options to use if the official layout is not used
    \PassOptionsToPackage{title}{appendix} % Prepends "Appendix #" to appendix sections
    \ifdef{\@reqbiblatexflag}{%
        \PassOptionsToPackage{%
            citestyle=numeric,% Part of process for combining numeric and authoryear styles
            sorting=none% References are only sorted by the order they're cited in
            }{biblatex}}{}
}

% Load minted package (needs Python's Pygments), more done with tcolorbox later
\ifdef{\@reqmintedflag}{
    \RequirePackage{currfile-abspath} % Only works reliably with TeX Live? (/a/548869)
        \getabspath{\jobname.log}
        \ifdefstrequal{\theabsdir}{\thepwd}% Detect changed output dir and pass to minted
            {}{\PassOptionsToPackage{outputdir=\theabsdir}{minted}}
    % TODO: Why doesn't cache option work if minted imported later?
    \RequirePackage[cache=false% Needed to prevent errors in TeXstudio
        ]{minted} % Needed for code blocks with syntax highlighting

    % Disable syntax error highlighting, since it gives false positives (/a/343506)
    \def\@disablefcolorbox{\renewcommand\fcolorbox[4][]{##4}}
    \AtBeginEnvironment{minted}{\@disablefcolorbox}
    \xpatchcmd{\inputminted}{\minted@fvset}{\minted@fvset\@disablefcolorbox}{}{}
    \xpatchcmd{\mintinline}{\minted@fvset}{\minted@fvset\@disablefcolorbox}{}{}
}{}
% Load pgfplots package (large, slow) and set defaults
\ifdef{\@reqpgfplotsflag}{
    \RequirePackage{pgfplots} % Needed for fancy graphs
    % Set default options for pgfplots graphs (most are related to the grid)
    \pgfplotsset{
        compat=1.16,% Lock version compatibility (search "compat" in log file for version)
        xlabel style={align=center},% Needed for line-breaks to work in xlabel
        ylabel style={align=center},% Needed for line-breaks to work in ylabel
        axis lines=left,% Place axis lines to left/bottom 
        grid=both,% Draw both major and minor grid lines
        major grid style={line width=0.2pt, draw=gray!50},% Make major grid lines thicker
        grid style={line width=0.1pt, draw=gray!10},% Make minor grid lines thinner
        minor tick num=4}% Draw 4 minor grid lines between major grid lines
}{}

\ifdef{\@lessxamkflag}{%
    \RequirePackage{microtype}% Improves justification spacing (not needed with ragged-right)
    \RequirePackage{textcomp}}{} % Makes siunitx and microtype compatible (/a/74673)
\RequirePackage[UKenglish]{babel} % Ensures consistent output regardless of system locale
\RequirePackage[T1]{fontenc} % Fixes problems related to using special/accented characters
\RequirePackage[utf8]{inputenc} % Allows for Unicode characters
\RequirePackage{tikz} % Needed for drawing shapes
    \usetikzlibrary{backgrounds}
\RequirePackage[fleqn% Align equations to left rather than center
    ]{amsmath} % Needed for math equations/formulas
    \patchcmd{\env@matrix}% Default to right-aligning matrices
        {\array{*\c@MaxMatrixCols c}}%
        {\array{*\c@MaxMatrixCols r}}{}{}
% TODO: Do more with math? (e.g. math class option, more stylings, (/a/28452), etc.)
%\RequirePackage{amssymb} % Needed for various math symbol commands
\RequirePackage{mathtools} % Needed for abs/norm commands (/a/43009)
    \DeclarePairedDelimiter\abs{\lvert}{\rvert}
        \let\@oldabs\abs
        \def\abs{\@ifstar{\@oldabs}{\@oldabs*}} % Make starred version default
    \DeclarePairedDelimiter\norm{\lVert}{\rVert}
        \let\@oldnorm\norm
        \def\norm{\@ifstar{\@oldnorm}{\@oldnorm*}} % Make starred version default
\RequirePackage{siunitx} % Makes dealing with SI units easier, adds some number formatting
\RequirePackage{float} % Needed for forcing caption placement, and provides [H] option
\RequirePackage[singlelinecheck=false% Disable automatic centering when caption fits on 1 line
    ]{caption} % Needed for formatting captions
\RequirePackage{setspace} % Needed for setting line spacing
\RequirePackage{tabularx} % Needed for horizontal table stretching
\RequirePackage[skins, breakable]{tcolorbox} % Needed for abstract page and cmd/code boxes
    \tcbset{%
        colback=blue!5!white,% Set background to light blue
        sharp corners,% XAMK is all about those sharp edges, judging from its logo
        top=0pc,bottom=0pc,% Corners are sharp, so extra padding is unnecessary
        left=0pc,right=0pc,% Left padding removed so line numbers show properly
        fontupper=\linespread{1}\selectfont,% Set line spacing to single
        breakable,enhanced jigsaw}% Properly break across pages
\RequirePackage{csquotes} % Recommended for use with biblatex
\RequirePackage[titletoc]{appendix} % Prepends "Appendix #" to appendix sections in ToC
    \pretocmd{\appendix}{\ClassError{xamk}%
        {appendix command not supported, use appendices environment instead}{}}{}{}
\RequirePackage[titles% Custom ToC formatting doesn't work without this...
    ]{tocloft} % Needed for ToC, LoF, and LoT formatting
\RequirePackage{parskip} % Needed for vertical spacing (must be loaded after tocloft)
\RequirePackage[nottoc, notbib]{tocbibind} % Needed to add LoF/LoT to ToC
\RequirePackage{enumitem} % Needed to remove vertical spacing from lists
    \setlist{nosep} % (/a/10689)
\RequirePackage{atenddvi} % Needed for cmd at very end of doc?
\RequirePackage[lastpage, user, abspage]{zref} % Needed for better labels
\RequirePackage{embedfile} % Needed for attaching arbitrary files to the PDF
%\RequirePackage{lipsum} % Needed for filler text

\pretocmd{\embedfile}{\def\@zipembeddedflag{}}{}{}
\AtEndDocument{% TODO: Detect any .zip file (/q/7653)
    \IfFileExists{./attach.zip}{% \ClassWarning doesn't seem to work
        \ifundef{\@zipembeddedflag}{\@latex@warning@no@line{%
            attach.zip file detected, but the embedfile command has not been used}}{}}{}}

% TODO: Add counter/label system (e.g. with "auto counter")? Title would then be mandatory.
% Create the minted "code" environment and input command using tcolorbox
\ifdef{\@reqmintedflag}{
    \setminted{% Set default options for minted and code environments/commands
        fontsize=\small,%
        breaklines,% Break lines rather than run off the page
        breakanywhere,% Break even if no spaces or other ideal breaking points
        autogobble}% Remove common leading whitespace

    \tcbuselibrary{minted, xparse}
    \tcbset{mintedstyle/.style={%
        listing only,% Disable the secondary code display
        listing engine=minted,% Use minted for syntax hightlighting
        minted language=#1}}% Default minted options inherited from \setminted command(s)
    \NewTCBListing{code}{ m O{} }{mintedstyle={#1}, #2}
    \NewTCBInputListing{\codeinput}{ m m O{} }{listing file={#1}, mintedstyle={#2}, #3}
}{}
% Create the listings "cmd" environment and input command using tcolorbox
\ifdef{\@reqlistingsflag}{% TODO: Find breakanywhere equivalent
    \RequirePackage{listings} % Useful for command-line snippets, less baggage than minted
    \lstset{% Set default options for listings and cmd environments/commands
        style=tcblatex,% Formatting can get screwed up without this (/a/554568)
        basicstyle=\small\ttfamily,% Use small font, and properly apply tt font
        breaklines,% Break lines rather than run off the page
        postbreak=\mbox{\textcolor{red}{$\hookrightarrow$}\space}}% Similar to minted's

    \tcbuselibrary{listings}
    \ifundef{\@reqmintedflag}{\tcbuselibrary{xparse}}{} % Don't redo
    \tcbset{listingsstyle/.style={%
        listing only,% Not available without minted/listings (don't put into global tcbset)
        listing engine=listings}} % Default listing options inherited from \lstset command(s)
    \NewTCBListing{cmd}{ O{} }{listingsstyle, #1}
    \NewTCBInputListing{\cmdinput}{ m O{} }{listing file={#1}, listingsstyle, #2}
}{}

% filecontents can't be put under ifdef (/a/44467)
\begingroup\newif\ifbibincluded
\ifdef{\@reqbiblatexflag}{\bibincludedtrue}{}
\ifbibincluded
\WarningFilter[temp-file]{latex}{Writing or overwriting file}
% Add doctype and lastmoddate bibliography database fields (/a/244144)
\begin{filecontents*}[overwrite]{xamkbibdm.dbx}
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
\end{filecontents*}
\DeactivateWarningFilters[temp-file]
\fi\endgroup

% biblatex complains if no .bib resources are given, so its usage has been made optional
\ifdef{\@reqbiblatexflag}{
    \RequirePackage[%
        datamodel=xamkbibdm,% Load entry/field definitions from xamkbibdm.dbx file
        backend=biber,
        bibstyle=authoryear,% Default style closest to Harvard, citestyle set elsewhere
        dashed=false,% Don't use dashes for duplicate author-years
        uniquename=init,% Needed so the following option doesn't give a warning
        giveninits=true,% Abbreviate names (except for last name)
        urldate=long,% Output urldate field in natural text format
        dateabbrev=false,% Use full month names instead of abbreviations
        defernumbers=true% Keep numbering consistent between bibliographies
        ]{biblatex} % Handles the bibliography and citations

    % Combine numeric and authoryear bibstyles when lessxamk is used (/a/314071)
    \ifdef{\@lessxamkflag}{\input{numeric.bbx}}{}

    \setlength\bibitemsep{0.5pc} % Add space between bibliography entries
    \setlength\bibhang{0pc} % Remove indent from bibliography

    % Prevents long urls from going into page margin, by adding arbitrary newline (/a/134281)
    \setcounter{biburllcpenalty}{7000}
    \setcounter{biburlucpenalty}{8000}

    % Create/modify bibliography string constants
    % Following/preceding periods/colons/spaces/etc. should be specified in the next section
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
    \renewrobustcmd*{\mkbibemph}{} % Disable all bib italics (e.g. for titles) (/a/551547)
        \protected\long\def\blx@imc@mkbibemph#1{#1} % Also disable internal macro
    \renewrobustcmd*{\mkbibacro}{} % Disable text monospacing (e.g. for ISBN/DOI/etc.)
    \DeclareNameAlias{sortname}{family-given} % Make last names come before first names
    \DeclareNameAlias{default}{family-given} % Needed for \fullcite (and others?)
    \DeclareDelimFormat{finalnamedelim}{% Use "&" instead of "and" (/a/549872)
        \ifnumgreater{\value{liststop}}{2}{\finalandcomma}{}% Preserves Oxford Comma option
        \addspace\&\space}% Based on biblatex's definition
    \DefineBibliographyExtras{UKenglish}{\def\finalandcomma{\addcomma}} % Enable Oxford Comma
    \DeclareFieldFormat{titlecase}{\MakeSentenceCase{#1}} % Make titles lowercase
    \DeclareFieldFormat{editortype}{\mkbibparens{#1}\nopunct} % Add parentheses (/a/419595)
        \DeclareFieldAlias{translatortype}{editortype}
    \DeclareDelimFormat{editortypedelim}{\addspace} % Remove comma before (/a/419595)
        \DeclareDelimAlias{translatortypedelim}{editortypedelim}
    \DeclareLabeldate{% Remove urldate as fallback date in bibliography (/a/525164)
        \field{date}\field{year}\field{eventdate}\field{origdate}\literal{nodate}}
    \xpatchbibmacro{date+extradate}% Remove date's parentheses, add period before (/a/428193)
        {\printtext[parens]}{\setunit*{\addperiod\addspace}\printtext}{}{}
    \DeclareFieldFormat{lastmoddate}{\bibstring{lastmodstr}\addspace#1}
    \DeclareFieldFormat{url}{\bibstring{urlpre}\addcolon\addspace\url{#1}}
    \DeclareFieldFormat{pages}{#1} % Remove "pp. " prefix from pages in bibliography
    \DeclareFieldFormat{postnote}{#1} % Remove "pp. " prefix from pages in citation postnotes
    \DeclareFieldFormat{urldate}{\mkbibbrackets{\bibstring{urlseen}\addspace#1}}
    \DeclareFieldFormat[article,inbook,incollection,inproceedings,patent,thesis,unpublished%
        ]{title}{#1} % Remove title quotes from bibliography (/a/94090)
    \DeclareFieldFormat[article,inbook,incollection,inproceedings,patent,thesis,unpublished%
        ]{citetitle}{#1} % Remove title quotes from citations (/a/94090)
    \xpretobibmacro{url+urldate}{% Print doctype and lastmoddate before url+urldate
        {\iffieldundef{url}{}% If doctype not specified, default to wwwdoc string
            {\iffieldundef{doctype}{\bibstring{wwwdoc}}{\printfield{doctype}}%
            \setunit*{\addperiod\addspace}}}%
        \iffieldundef{lastmodyear}{}% (/a/244144)
            {\printlastmoddate\setunit*{\addperiod\addspace}}}{}{}

    \defbibenvironment{notnumbers}% Needed for authoryear-like bibstyle (/a/314071)
        {\list{}{%
            \setlength{\leftmargin}{\bibhang}%
            \setlength{\itemindent}{-\leftmargin}%
            \setlength{\itemsep}{\bibitemsep}%
            \setlength{\parsep}{\bibparsep}}}%
        {\endlist}{\item}

    \DeclarePrintbibliographyDefaults{heading=bibintoc} % Add bibliography to ToC
    \DeclareBibliographyCategory{cited} % All cited references added to this
    \AtEveryCitekey{\addtocategory{cited}{\thefield{entrykey}}} % (/a/6977)
    \AfterEndPreamble{\nocite{*}} % Needed so \printbibliography[notcategory=cited] works
    \DeclareBibliographyCategory{fullcitedfig} % References cited in figures added to this
    \DeclareBibliographyCategory{fullcitedtab} % References cited in tables added to this
    \defbibfilter{notfigtab}{
        category=cited and
        not category=fullcitedfig and
        not category=fullcitedtab}
    \defbibfilter{notfig}{
        category=cited and
        not category=fullcitedfig}
    \defbibfilter{nottab}{
        category=cited and
        not category=fullcitedtab}
}{}
\ExplSyntaxOn % Can't be put under ifdef (would put at top, but it breaks xpatch (/a/558525))
\ifdef{\@reqbiblatexflag}{ % Continues from previous \@reqbiblatexflag ifdef
    \keys_define:nn { xamk/makebib }{ % l3keys package used for named args (/a/518230)
        extra .bool_set:N = \l__makebib_extra_bool, % Print bibliography for uncited references
        lof .bool_set:N = \l__makebib_lof_bool, % Print list of figures
        lot .bool_set:N = \l__makebib_lot_bool} % Print list of tables
    % Command to render bibliography (and optionally LoF/LoT)
    \NewDocumentCommand{\makebibliography}{ O{} }{
        \keys_set:nn { xamk/makebib }{ extra=false,#1 }
        \keys_set:nn { xamk/makebib }{ lof=false,#1 }
        \keys_set:nn { xamk/makebib }{ lot=false,#1 }

        \clearpage
        \begin{singlespace}
        % TODO: Apparently section not output if empty, but might not always be the case
        \WarningFilter[temp-bib]{latex}{Empty bibliography} % If bib empty, suppress warning
        \ifdef{\@lessxamkflag}
            {\printbibliography[category=cited]}
            {\bool_if:NTF\l__makebib_lof_bool % References left out of bib if in LoF or LoT
                {\bool_if:NTF\l__makebib_lot_bool
                    {\printbibliography[filter=notfigtab]}
                    {\printbibliography[filter=notfig]}}
                {\bool_if:NTF\l__makebib_lot_bool
                    {\printbibliography[filter=nottab]}
                    {\printbibliography[category=cited]}}}
        \bool_if:NT\l__makebib_extra_bool{ % Print section for uncited references
            \ifundef{\@lessxamkflag} % If bibstyle numeric, make authoryear-like
                {\printbibliography[title={Further~Reading},notcategory=cited]}
                {\printbibliography[title={Further~Reading},notcategory=cited,
                    env=notnumbers,omitnumbers]}}
        \DeactivateWarningFilters[temp-bib]

        \clearpage
        \bool_if:NT\l__makebib_lof_bool{\listoffigures}
        \bool_if:NT\l__makebib_lot_bool{\listoftables}
        \end{singlespace}

        \clearpage
    }
}{}

% This section is for setting up the \labelcaption and \citecaption commands
\AfterEndPreamble{ % Needed because something's modifying these commands later on...
    \let\@oldcaption\caption % TODO: Do something about other forms (e.g. starred)?
    \let\@oldlabel\label}
\newcommand*\@disablecaptioncmds[1]{
    \pretocmd{\caption}{\ClassError{xamk}
        {caption~command~not~supported~in~#1~environment,~
        use~citecaption~or~labelcaption~instead}{}}{}{}
    \pretocmd{\label}{\ClassError{xamk}
        {label~command~not~supported~in~#1~environment,~
        use~citecaption~or~labelcaption~instead}{}}{}{}}
\newrobustcmd*\@fullcitehyper[1]{ % Used to move citation hyperrefs to the LoF/LoT
    \Hy@raisedlink{\hypertarget{cite.\the\c@refsection @#1}{}}\protect\fullcite{#1}}
\NewDocumentCommand\@adddotifnotpunct{ m }{ % TODO: Punctuation from commands? (e.g. \lipsum)
    #1\str_case_e:nnF { \tl_item:Nn { #1 } { -1 } } % Check last character
        {{.}{}{,}{}{?}{}{!}{}} % If punctuation (.,?!), do nothing
        {.}} % Otherwise, add period
% Commands to set caption with label (and citation, and prepare reference for LoF/LoT)
\NewDocumentCommand\@makecaptioncmds{ m m m }{
    \@disablecaptioncmds{#1}
    \ifdef{\@reqbiblatexflag}{
        \NewDocumentCommand\citecaption{ m O{##3} m }{
            \ifundef{\@lessxamkflag}
                {\@oldcaption[#3~\@adddotifnotpunct{##2}~\@fullcitehyper{##1}]
                    {##3~\protect\parencite{##1}}}
                {\@oldcaption[##2~\protect\parencite{##1}]
                    {##3~\protect\parencite{##1}}}
            \@oldlabel{#2:##1}
            \addtocategory{fullcited#2}{##1}}}{}
    \NewDocumentCommand\labelcaption{ m O{##3} m }{
        \ifundef{\@lessxamkflag}
            {\@oldcaption[#3~\@adddotifnotpunct{##2}]{##3}}
            {\@oldcaption[##2]{##3}}
        \@oldlabel{#2:##1}}}
\ExplSyntaxOff
\AtBeginEnvironment{figure}{%
    \@makecaptioncmds{figure}{fig}{\figurename\ \thefigure.}}
\AtBeginEnvironment{table}{%
    \@makecaptioncmds{table}{tab}{\tablename\ \thetable.}}

% TODO: Check (/a/54607) for fix for page broken urls affecting footer/header
\RequirePackage[%
    hidelinks,% Remove annoying borders
    colorlinks=true,% Re-enable colors that were disabled by hidelinks
    urlcolor=blue,%
    linkcolor=black,%
    citecolor=black%
    ]{hyperref} % Needed for urls/hyperlinks/etc. (must be loaded after biblatex)

% Used in preamble, so \restoregeometry reverts to this (unless lessxamk is used)
\newcommand*\@xamkpagegeometry{% Official XAMK page margins
    \newgeometry{left=4.3cm, right=2.0cm, top=2.25cm, bottom=1.25cm,%
        headheight=15pt, headsep=15pt}} % Places page number ~1cm from top of page
\newcommand*\@titlepagegeometry{% Custom page margins for the title page
    \newgeometry{left=3.0cm, right=3.0cm, top=3.0cm, bottom=3.0cm}}
\newcommand*\@thesisabstractgeometry{% Custom page margins for thesis abstract
    \newgeometry{left=1.5cm, right=1.5cm, top=1.5cm, bottom=1.5cm}}
\newcommand*\@tableofcontentsgeometry{% Custom page margins for the table of contents
    \newgeometry{left=1.75cm, right=1.75cm, top=1.75cm, bottom=1.75cm}}
\RequirePackage[left=1.5cm, right=1.5cm, top=2.0cm, bottom=2.0cm%
    ]{geometry} % Set page margins (must be loaded after hyperref? (/a/26592))
    \ifundef{\@lessxamkflag}{\@xamkpagegeometry}{}

% Allows customization of the header and footer
\RequirePackage{fancyhdr} % Must be loaded after setting default geometry in preamble
    \pagestyle{fancy}
    \fancyhf{} % Clear header and footer defaults (/a/13897)
    \renewcommand\headrulewidth{0pc} % Remove header bar (/a/13897)
    % Clarify: Page numbering as "# / #"? Should appendices be included?
    \ifundef{\@lessxamkflag}% Also print total page count after current page number
        {\fancyhead[C]{\makebox[\textwidth][c]{% Centering not needed now, but maybe later?
            \textcolor{gray}{\thepage\ / \@xamk@pc}}}}% (/a/201063)
        {\fancyfoot[C]{\makebox[\textwidth][c]{\thepage\ / \@xamk@pc}}}%

% Official section/ToC formatting
\ExplSyntaxOn
\newcommand*\@xamktoclayout{
    % Make section/subsection text size same as normal text
    \patchcmd{\section}{\Large}{\normalsize}{}{}
    \patchcmd{\subsection}{\large}{\normalsize}{}{}
    % Capitalize sections (/a/555656)
    \let\old_section\section
    \RenewDocumentCommand{\section}{ s o m }{
        % TODO: Remove \tl_upper_case fallback (OL2020 and TL2021?)
        \tl_set:Nx\l_section_upper{\cs_if_exist:NTF{\text_uppercase:n}
            {\text_uppercase:n{##3}}{\tl_upper_case:n{##3}}}
        \IfBooleanTF{##1}
            {\old_section*{\l_section_upper}}
            {\IfNoValueTF{##2}
                {\old_section{\l_section_upper}}
                {\old_section[##2]{\l_section_upper}}}}

    \renewcommand{\cftdot}{\textcolor{gray}{.}}
    \renewcommand{\cftdotsep}{2} % Make dots in ToC/LoF/LoT closer together
    \renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}} % Add dotted line to sections in ToC
    % Remove bold font weight from sections in ToC
    \renewcommand{\cftsecfont}{}
    \renewcommand{\cftsecpagefont}{}

    % Make sections in ToC uppercase (/a/156917)
    \let\@oldcontentsline\contentsline
    \def\contentsline##1##2{
        \expandafter\ifx\csname l@##1\endcsname\l@section
            \expandafter\@firstoftwo
        \else
            \expandafter\@secondoftwo
        \fi
        {\@oldcontentsline{##1}{\MakeUppercase{##2}}}
        {\@oldcontentsline{##1}{##2}}
    }
}
\ExplSyntaxOff

% Removes page number(s) from ToC page(s) (/a/180877)
\let\@oldtableofcontents\tableofcontents
\renewcommand\tableofcontents{ % If not lessxamk, set custom geometry
    \ifundef{\@lessxamkflag}{\@tableofcontentsgeometry}{}
    \pagestyle{empty}
    {
        \renewcommand{\thispagestyle}[1]{}
        \@oldtableofcontents
    }
    \clearpage\ifundef{\@lessxamkflag}{\restoregeometry}{}
    \pagestyle{fancy}
}

% Add space between LoF/LoT entries
\setlength{\cftbeforefigskip}{0.5pc}
\setlength{\cftbeforetabskip}{0.5pc}
% Section titles dynamically spaced from section numbers (/a/64124)
%\renewcommand{\numberline}[1]{\@cftbsnum #1\@cftasnum\quad\@cftasnumb} % Messes up LoF/LoT
% TODO: Set proper spacing around floats
% Official list of figures/tables formatting
\newcommand*\@xamkloftlayout{
    \renewcommand{\@tocrmarg}{2.55em plus1fil} % Set ToC/LoF/LoT entries ragged-right (/a/62006)
    % Remove LoF/LoT indents (fig/tab numbers have been moved into captions themselves)
    \cftsetindents{figure}{0pc}{0pc}
    \cftsetindents{table}{0pc}{0pc}

    \floatstyle{plaintop}\restylefloat{table} % Force table captions above tables (/a/22754)
    \floatstyle{plain}\restylefloat{figure} % Force figure captions below figures
}

% Permanent, but "Before" needed for last footer to work, and appendices should be last anyways
\BeforeBeginEnvironment{appendices}{
    \clearpage\pretocmd{\section}{%
        \ifundef{\@firstapppass}{% Label used to get first appendix page number
            \def\@firstapppass{}% Only run once (on first appendix)
            \zref@label{firstappstart}}{}}{}{}
    \pagenumbering{arabic} % Reset numbering
    \renewcommand*{\thepage}{A\arabic{page}} % (/a/59574)
    \ifundef{\@lessxamkflag}% Clarify: Keep current page numbering, or (/a/239162)?
        {\fancyhead[C]{\makebox[\textwidth][c]{\textcolor{gray}{\thepage\ / A\@xamk@apc}}}}%
        {\fancyfoot[C]{\makebox[\textwidth][c]{\thepage\ / A\@xamk@apc}}}{}
}
% Official appendix formatting
\newcommand*\@xamkapplayout{
    % Make appendix section titles use numbers instead of letters
    \apptocmd{\appendices}{\renewcommand{\thesection}{\arabic{section}}}{}{}
    \AtBeginEnvironment{appendices}{
        \pretocmd{\section}{\resetpageaux}{}{} % Force appendix sections to start from new pages
        \renewcommand*{\@seccntformat}[1]{} % Remove appendix section title numbers
        \singlespacing % Set line spacing to 1
        \setlength{\parskip}{1pc} % Match paragraph spacing with line spacing

        % Add "Appendix # (page # of #)" to the right header
        \fancyhead[R]{\textcolor{gray}{Appendix \thesection\ (\apppagenumbers)}}

        % Maintain total page count for each appendix section (/a/82560)
        \newcounter{pageaux}
        \def\currentauxref{PAGEAUX1}
        \newcommand{\apppagenumbers}{%
            \stepcounter{pageaux}% Incremented by right header every page
            page \thepageaux\ of \ref*{\currentauxref}}
        \newcommand{\resetpageaux}{%
            \clearpage
            \edef\@currentlabel{\thepageaux}\label{\currentauxref}%
            \xdef\currentauxref{PAGEAUX\thepage}%
            \setcounter{pageaux}{0}}
        \AtEndDvi{\edef\@currentlabel{\thepageaux}\label{\currentauxref}}
    }
    \AtEndEnvironment{appendices}{\clearpage} % Needed so appendix page counting works properly
}
\AfterEndEnvironment{appendices}{ % TODO: Find way to detect/block all content
    \RenewDocumentCommand{\section}{ s o m }{\ClassError{xamk}%
        {Nothing should come after the appendices environment}{}}
    \RenewDocumentCommand{\subsection}{ s o m }{\ClassError{xamk}%
        {Nothing should come after the appendices environment}{}}
    \RenewDocumentCommand{\subsubsection}{ s o m }{\ClassError{xamk}%
        {Nothing should come after the appendices environment}{}}
}

% Apply the official XAMK layout (can be disabled with the lessxamk class option)
\ifundef{\@lessxamkflag}{
    \RequirePackage{helvet} % Provides the helvet font
        \renewcommand*{\familydefault}{\sfdefault} % Set Helvet as default font
        \RequirePackage[helvet]{sfmath} % Set Helvet as default font for math
    \@xamktoclayout % Apply official section/ToC formatting
    \@xamkloftlayout % Apply official list of figures/tables formatting
    \@xamkapplayout % Apply official appendix formatting
    \onehalfspacing % Set line spacing to 1.5
    \AtBeginDocument{\raggedright} % Disable text justification (TODO: Is ragged2e needed?)
    \pretocmd{\include}{\ClassError{xamk}% There shouldn't be incomplete pages between sections
        {include command not supported, use input command instead}{}}{}{}
}{}

% Colors used in title page
\definecolor{xamklightblue}{RGB}{200, 200, 255}
\definecolor{xamkdarkblue}{RGB}{11, 124, 164}

% TikZ code for the page border used in the title page
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
% TikZ code for the XAMK logo
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
% Command to insert the 2 vector graphics into the title page
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

% Include the title page in page numbering (/a/172005)
\renewenvironment{titlepage}{\thispagestyle{empty}}{} % Page number not printed though

\newcommand*\@placehold[1]{$\langle$#1$\rangle$} % Places < > around text

% The list of students. Supported formats are "<name> | <number> | <group>", and "<name>".
\def\@xamkdefaultstudent{%
    \@placehold{Student Name} | \@placehold{Student Number} | \@placehold{Group ID}}
\def\@xamkdefaultstudentname{\@placehold{First-name Last-name}}
\newcounter{studentcount}
\newcounter{studentcounttemp}
\NewDocumentCommand\xamkstudent{ m g g }{%
    \stepcounter{studentcount}%
    \IfNoValueTF{#3}%
        {\listadd\@xamkstudentlist{#1}}%
        {\listadd\@xamkstudentlist{#1 | #2 | #3}}}
\newcommand*\@printxamkstudentlist{% Print list without \par for last element (/a/33840)
    \setcounter{studentcounttemp}{\value{studentcount}}%
    \def\do##1{%
        \ifnumequal{\value{studentcounttemp}}{1}{##1}{##1\par}%
        \addtocounter{studentcounttemp}{-1}}%
    \dolistloop{\@xamkstudentlist}}
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

% The thesis type (Bachelor's, Master's, etc.). Defaults to "Bachelor's Degree".
\newcommand*\xamkdegreetype[1]{\def\@xamkdegreetype{#1}}
\xamkdegreetype{Bachelor's Degree}
% The degree programme the thesis was written for. Defaults to "<Degree Programme>".
\newcommand*\xamkdegreeprogramme[1]{\def\@xamkdegreeprogramme{#1}}
\xamkdegreeprogramme{\href{https://student.xamk.fi/studies-and-supporting-services/Documents/degree_titles.pdf}{\@placehold{Degree Programme}}}

\newcommand*\@invalidate@title@cmds[1]{% Redefine commands to give error
    \RenewDocumentCommand\xamkstudent{ m g g }{#1}
    \renewcommand*\xamkpapertitle[1]{#1}
    \renewcommand*\xamkpapersubtitle[1]{#1}
    \renewcommand*\xamkpapertype[1]{#1}
    \renewcommand*\xamkcoursename[1]{#1}
    \renewcommand*\xamkpaperdate[1]{#1}
    \renewcommand*\xamkdegreetype[1]{#1}
    \renewcommand*\xamkdegreeprogramme[1]{#1}
}

\ExplSyntaxOn
% Set option for \maketitle command to be a thesis title page
\keys_define:nn { xamk/maketitle }
    {thesis .bool_set:N = \l__maketitle_thesis_bool} % Print thesis title page and abstract
% Command for rendering the title page
\renewcommand*\maketitle[1][]{
    \keys_set:nn { xamk/maketitle }{ thesis=false,#1 }
    \@invalidate@title@cmds{\ClassError{xamk}
        {This~command~must~be~used~before~the~maketitle~command}{}}

    \@titlepagegeometry
    \begin{singlespace}
    \begin{titlepage}
        \begin{center}
        \@titlepageimages
        {\Large\bf\setlength{\parskip}{1pc}
            \ifdef{\@xamkstudentlist}
                {{\setlength{\parskip}{0.25pc}\@printxamkstudentlist\par}}
                {\bool_if:NTF\l__maketitle_thesis_bool
                    {\@xamkdefaultstudentname}{\@xamkdefaultstudent}\par}
            \vspace*{2pc}
            {\huge\@xamkpapertitle\par}
            \ifdef{\@xamkpapersubtitle}{{\LARGE\@xamkpapersubtitle\par}}{}
            \vspace*{2pc}
            \bool_if:NTF\l__maketitle_thesis_bool
                {\@xamkdegreetype\par\@xamkdegreeprogramme\par}
                {\@xamkpapertype\par\@xamkcoursename\par}
            \vspace*{2pc}
            \@xamkpaperdate\par
        }
        \end{center}
    \end{titlepage}
    \end{singlespace}
    \bool_if:NT\l__maketitle_thesis_bool{\clearpage\restoregeometry\@makethesisabstract}
    \clearpage\restoregeometry
}
\ExplSyntaxOff

% Who commissioned the thesis. Defaults to "<Commissioner>".
\newcommand*\xamkthesiscommissioner[1]{\def\@xamkthesiscommissioner{#1}}
\xamkthesiscommissioner{\@placehold{Commissioner}}
% Who supervised the writing of the thesis. Defaults to "<Supervisor>".
\newcommand*\xamkthesissupervisor[1]{\def\@xamkthesissupervisor{#1}}
\xamkthesissupervisor{\@placehold{Supervisor}}
% Keywords for the thesis. Defaults to "<Keywords>".
\newcommand*\xamkthesiskeywords[1]{\def\@xamkthesiskeywords{#1}}
\xamkthesiskeywords{\@placehold{Keywords}}
% Abstract for the thesis. Expects a file name as input. Defaults to "<Thesis Abstract>".
\newcommand*\xamkthesisabstractfile[1]{\def\@xamkthesisabstractfile{#1}}
\newcommand*\@invalidate@abstract@cmds[1]{% Redefine commands to give error
    \renewcommand*\xamkthesiscommissioner[1]{#1}
    \renewcommand*\xamkthesissupervisor[1]{#1}
    \renewcommand*\xamkthesiskeywords[1]{#1}
    \renewcommand*\xamkthesisabstractfile[1]{#1}
}

\AtBeginDocument{% Label math doesn't work if done within preamble
    % Early expansion needed so ifdefstring test works
    \edef\@xamk@pc{% Number of pages until appendices (or all pages, if no appendices)
        \zref@ifrefundefined{firstappstart}%
            {\zpageref{LastPage}}%
            {\the\numexpr\zref@extractdefault{firstappstart}{abspage}{1}-1\relax}}
    \edef\@xamk@apc{% Number of appendix pages (or 0, if no appendices)
        \zref@ifrefundefined{firstappstart}%
            {0}{\the\numexpr\zref@extractdefault{LastPage}{abspage}{1}%
                -\zref@extractdefault{firstappstart}{abspage}{1}+1\relax}}
}
% Command for rendering the thesis abstract
\newcommand*\@makethesisabstract{
    \@invalidate@abstract@cmds{\ClassError{xamk}%
        {This command must be used before the maketitle command}{}}
    % If lessxamk, use default parskip, otherwise use 1pc (even default needs explicit setting)
    \newlength{\abstractparskip}\ifundef{\@lessxamkflag}%
        {\setlength{\abstractparskip}{1pc}}%
        {\setlength{\abstractparskip}{\parskip}}
    % tcolorbox's [parbox=false] could also be used (/a/154994), but that affects all rows
    \newenvironment{tcbrow}{\setlength{\parskip}{\abstractparskip}}{}

    \@thesisabstractgeometry
    \begin{singlespace}
    \thispagestyle{empty} % Don't print page number
    \begin{tikzpicture}[remember picture, overlay, x=0.33pt, y=0.33pt]
        \xamkdrawlogo
    \end{tikzpicture}
    \begin{tcolorbox}[%
    enhanced,% Needed for segmentation style option
    segmentation style={% Use solid rather than dashed divider lines
        black, solid, line width=1pt},%
    space to upper,% Make extra empty space go above \tcblower
    height fill,% Make table fill the remaining page height
    sharp corners,% Make table corners sharp rather than rounded
    colback=white,% Background color
    middle=0pc,boxsep=0.5pc]% Inner margins
        \ifundef{\@lessxamkflag}{\raggedright}{}
        \noindent\begin{tabularx}{\textwidth}% 3 columns -> sum must be exactly 3
        {@{} >{\hsize=1.15\hsize}X >{\hsize=1.15\hsize}X >{\hsize=0.7\hsize}X @{}}
            \textbf{Author\ifnumgreater{\value{studentcount}}{1}{s}{}} % "s" added if multiple
            \vspace*{0.5pc}

            \ifdef{\@xamkstudentlist}{\@printxamkstudentlist}{\@xamkdefaultstudentname}
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
        \vspace*{-0.5pc} % Center page counts (gets pushed down even with negative vspace?)
        \@xamk@pc\ page\ifdefstring{\@xamk@pc}{1}{}{s}

        \ifdefstring{\@xamk@apc}{0}% Hide if 0
            {}{\@xamk@apc\ page\ifdefstring{\@xamk@apc}{1}{}{s} of appendices}
        \end{tabularx} % Clarify: Rephrase as "# appendix page(s)"? More space.
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

% Uncomment and place more '\listeadd's to find compilation bottlenecks
%\AfterEndPreamble{
%    \listeadd\@timerlist{end: \the\pdfelapsedtime}
%    \renewcommand*{\do}[1]{\typeout{#1}}
%    \dolistloop{\@timerlist}}

\endinput