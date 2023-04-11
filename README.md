# CryptoHint

<b>CryptoHint helps solve cryptogram puzzles.</b>

CryptoHint is an electronic cryptogram dictionary based on
letter patterns. 
Just type a word from a cryptogram - the longer the better! -
and CryptoHint will list all the words matching the word's letter
pattern. Select a word from that list and its letters will be
added to a <b>letter substitution map</b>.
You can also make individual
letter guesses to add to the map.  <b>Subsequent word searches will
improve</b> as you fill in the substitution map.
Cryptogram dictionary books exist, but
CryptoHint performs the same function electronically and fits in
your pocket.

<em>For iPhone and iPod Touch with iOS 3.1.3 or later, up to but not including iOS 8; tested on
iOS 4. (2010-2014)</em>


<img src="Website/images/CryptoHint screenshots/Main.png" height="345" width="240" alt="Main" />
<img src="Website/images/CryptoHint screenshots/MainEntry.png" height="345" width="240" alt="Enter cryptogram word" />
<img src="Website/images/CryptoHint screenshots/Match.png" height="345" width="240" alt="Matching words, sorted by commonality" />
<img src="Website/images/CryptoHint screenshots/MatchSelected.png" height="345" width="240" alt="Match word selected" />
<img src="Website/images/CryptoHint screenshots/Pickers.png" height="345" width="240" alt="Individual letter pickers" />
<img src="Website/images/CryptoHint screenshots/HelpExample.png" height="345" width="240" alt="Built-in help screen" />


## Instructions

The CryptoHint Main screen has 3 main input fields.

<img src="Website/images/CryptoHint screenshots/Main-ShrunkNumbered.png"
alt="image" />

The <strong>text field (1)</strong> is used for entry of a cryptogram
word. When empty it displays a <em>"Enter cryptogram word here"</em>
prompt. When the user taps the text field the keyboard will be
displayed; hitting the Return key will dismiss the keyboard and allow
the entered word to be parsed. Parsing consists of removing any
numeric digits and punctuation and converting the word to uppercase.
The wordlist will then be searched for words matching the cryptogram
word letter pattern.

The <strong>letter substitution map (2)</strong> displays how letters
in the cryptogram are mapped to letters in the solution. Tapping the
display leads the user to the substitution letter picker screen. When
CryptoHint starts up the map is empty; as the user specifies
cryptogram/solution letter pairs and cryptogram word/solution word
matches, the substitution map is filled in and used to improve
subsequent word searches.

The table lists a <strong>history of the most recent cryptogram words
(3)</strong>. Tapping on a given word in the list will repeat a
search for that word. This saves the user from retyping the
cryptogram word.

Type a single word from a cryptogram in the text field. In this
example we'll type 'XJFFXU'. CryptoHint will take up to a few seconds
to search for words that match the letter pattern, e.g. a 6-letter
word where the first and fifth letters are identical and the third
and fourth letters are identical. If there are any letters
established in the letter substitution map the search will filter the
word matches based on the substitution map. If any words are found
the Match screen will appear.
        
<img src=
"Website/images/CryptoHint screenshots/Match-Shrunk.png" />

The CryptoHint Match screen displays the <strong>list of words
matching the cryptogram word</strong> while complying with the
current letter substitution map. If the user selects one of the
words, the letters of that word are added to the letter substitution
map.

The <strong>selector</strong> at the bottom of this screen allows the
list to be displayed either <strong>alphabetically or by letter
frequency</strong>; common words are listed higher than normal in the
letter frequency view.

</p><img src="Website/images/CryptoHint screenshots/Pickers-Shrunk.png" alt="image" />

You can also select individual letters in the letter substitution map
by tapping the map itself. The screen that allows you to make the
selections appears - it has two picker wheels and a selection button.
The <strong>left wheel lists the letters from the
cryptogram</strong>; the <strong>right wheel lists available letters
for the solution</strong>; tap the selection button when the
approrpriate cryptogram letter is lined up with the desired solution
letter.


## Discussion

The addition of the list of recent cryptogram words came after
testing an earlier version of CryptoHint against real cryptograms and
crypto family puzzles. At the start of a given puzzle a word might
have an excessively long list of matches and I'd try other words in
the puzzle; I'd eventually need to reenter the previous word after a
while, which could be a pain. I thought, <strong>'Why can't the app
remember what I tried earlier so I don't need to retype it?'</strong>
So I added the feature and saved a lot of retyping.

The use of picker wheels to specify letter substitution pairs
eliminates the drudgery of having two text fields for the letter
pairs, parsing to account for multiple letter entries, punctuation,
numeric digits, checks for letters already used, and so on. Again,
saves a lot of typing. Afterwards I found a cryptogram puzzle app
that does the same thing with picker wheels, so it's not an original
idea.

CryptoHint uses <strong>Courier</strong> and <strong>Marker
Felt</strong> fonts to differentiate between cryptogram ciphertext
and solution plaintext wherever possible. When I started learning how
to solve cryptograms by hand so many years ago I'd solve the
cryptograms in the newspaper by writing the solution directly
underneath the printed puzzle. Courier is the closest to what appears
in newspaper cryptogram puzzles, and Marker Felt is the only
available font on the iPhone that has a handlettered look. For the
display of the substitution map, I had to make do with Courier in
italics since Marker Felt is not a monospaced font.

## Version history

<strong>1.0.1 - 2011.06.23</strong><br />
The Frequency sort now considers the word frequency in addition
to letter frequency: common words will tend to be listed
before obscure words.

<strong>1.0.0 - 2010.10.14</strong><br />
CryptoHint now available in the iTunes App Store

<strong>0.8.2 - 2010.10.05</strong><br />
Letter substitution map plaintext now in maroon

<strong>0.8.1 - 2010.10.04</strong><br />
Issue 26 closed: Copied code from CryptoHintAppDelegate.m, 
applicationWillTerminate: to save data into 
applicationDidEnterBackground:.

<strong>0.8.0 - 2010.10.02</strong>

- Issue 24 closed: Startup screen displays "Loading..." message

- Issue 25 closed: Letter substitution map plaintext now in another
color other than black

<strong>0.7.5 - 2010.09.14</strong><br />
CryptoHint memory leaks fixed

<strong>0.7.4 - 2010.09.13</strong>

- Issue 9 closed: Help/Description page describes crypto-family
puzzles

- Issue 20 closed: Help pages for Main, Match and Letter
Substitution screens include screenshots

- Issue 21 closed: Added a few sample cryptograms to the About
screen

- Issue 22 closed: Version history deleted from About screen

- Issue 23 closed: Default screen status bar blacked out

<strong>0.7.3 - 2010.09.11</strong><br />
Issue 19 closed: Help button always returns to Help home page

<strong>0.7.2 - 2010.09.08</strong><br />
Requirement 24: Application shall account for bad network connection
when attempting to access application website

<strong>0.7.1 - 2010.09.07</strong>

- Issue 18 closed: Reworded Issue 11 description

- Issue 2 closed: If last substitution pair selected (no more
letters available), control returns to previous screen

- Issue 3 closed: If substitution map is full and user taps it,
control moves directly to substitution list for editing

- Issue 4 closed: Reset button on main screen clears status

- Issue 5 closed: Subsitution list now sorted alphabetically

- Issue 6 closed: If user deletes last subsitution pair at
substitution list, control returns to previous screen

- Issue 10 closed: Selected word from recent word list no longer
deselected with animation - prevents fading during search

- Issue 14 closed: Home button on website screen toolbar now
active, points to CryptoHint home page

<strong>0.7.0 - 2010.09.03</strong>

- Requirement 20: Application shall save substitution map to a file
on application termination

- Requirement 21: Application shall read substitution map from a
file on application startup

- Requirement 22: Application shall save history of cryptogram
words to a file on application termination

- Requirement 23: Application shall read history of cryptogram
words from a file on application startup

<strong>0.6.2 - 2010.09.02</strong>

- Issue 16 closed: Picker labels modified and moved to picker
window

- Issue 11 closed: Email option now points to CryptoHint's Email
address.

<strong>0.6.1 - 2010.08.27</strong><br />
Issue 15 closed: When attempting to send Email, additional check on
canSendMail performed before calling modal in-app Email.

<strong>0.6.0 - 2010.08.27</strong>

- Requirement 19: Application shall have feature to visit
application website

- Issue 13 closed: "Plus" disclosure indicators made smaller with
transparent backgrounds in order to reduce emphasis

<strong>0.5.1 - 2010.08.26</strong><br />
Issue 12 closed: Main screen Reset button clears recent cryptogram
word list if substitution map is already cleared

<strong>0.5.0 - 2010.08.26</strong><br />
Requirement 18 - Application shall allow user to send Email to
Bersalona Technologies LLC

<strong>0.4.2 - 2010.08.25</strong><br />
Issue 1 closed: If a selected match and cryptogram words have any
matching letters, selected match word is invalidated

<strong>0.4.1 - 2010.08.25</strong><br />
Issue 7 closed: Help screen now modal

<strong>0.4.0 - 2010.08.24</strong><br />
Requirement 17: Application shall have an About screen specifying
version number and date

<strong>0.3.0 - 2010.08.24</strong><br />
Requirement 16: Application shall have a Help screen

<strong>0.2.9 - 2010.08.23</strong>

- Requirement 15: Application may maintain a list of recently typed
words for convenient re-entry into text field

- Requirement 14: Application shall allow user to delete any given
substitution pair

<strong>0.2.6 - 2010.08.20</strong><br />
Requirement 13: Application shall allow user to specify letter
substitutions by selection from match word list

<strong>0.2.2 - 2010.08.19</strong>

- Requirement 12: Application shall filter list of words matching
the cryptogram word letter pattern through all specified substitution
pairs

- Requirement 11: Application shall allow user to delete all
substitution pairs

- Requirement 10: Application shall allow user to specify letter
substitutions by individual letter pairs

<strong>0.1.2 - 2010.08.12-16</strong>

- Requirement 9: Application may show match words in alphabetical
or letter frequency order

- Requirement 8: Application shall show an activity indicator while
searching for match words

<strong>0.1.0 - 2010.08.06-10</strong>

- Requirement 7: Application shall rank matching words based on
letter frequency statistics

- Requirement 6: Application shall search a database for words
matching the cryptogram word's letter pattern

- Requirement 5: Application shall inform user of the count of
words matching the cryptogram word letter pattern

- Requirement 4: Application shall be implemented in English with a
26-letter Latin alphabet

- Requirement 3: Application shall strip cryptogram word of numeric
digits, punctuation and spaces

- Requirement 2: Application shall convert cryptogram word to
uppercase

- Requirement 1: Application shall allow user to enter a cryptogram
word in mixed case and include punctuation, numeric digits and spaces
