/*
 * This file is part of the HSTracker package.
 * (c) Benjamin Michotte <bmichotte@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 13/02/16.
 */

import Cocoa

class LanguageChooser: NSWindowController, NSComboBoxDataSource {

    @IBOutlet var hstrackerLanguage: NSComboBox?
    @IBOutlet var hearthstoneLanguage: NSComboBox?

    var completionHandler: (() -> Void)?

    let hsLanguages = ["deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "plPL", "ptBR", "ruRU", "zhCN", "zhTW", "jaJP"]
    let hearthstoneLanguages = ["de_DE", "en_US", "es_ES", "es_MX", "fr_FR", "it_IT", "ko_KR", "pl_PL", "pt_BR", "ru_RU", "zh_CN", "zh_TW", "ja_JP"]
    let hstrackerLanguages = ["de", "en", "fr", "it", "pt-br", "zh-cn", "es"]

    override func windowDidLoad() {
        super.windowDidLoad()

        hstrackerLanguage!.usesDataSource = true
        hstrackerLanguage!.dataSource = self

        hearthstoneLanguage!.usesDataSource = true
        hearthstoneLanguage!.dataSource = self
    }
    
    // MARK: - Button actions
    @IBAction func exit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(nil)
    }

    @IBAction func save(sender: AnyObject) {
        let hstracker = hstrackerLanguages[hstrackerLanguage!.indexOfSelectedItem]
        let hearthstone = hsLanguages[hearthstoneLanguage!.indexOfSelectedItem]

        Settings.instance.hearthstoneLanguage = hearthstone
        Settings.instance.hsTrackerLanguage = hstracker

        if let completionHandler = self.completionHandler {
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler()
            }
        }
        self.window!.close()
    }

    // MARK: - NSComboBoxDataSource methods
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        if aComboBox == hstrackerLanguage {
            return hstrackerLanguages.count
        } else if aComboBox == hearthstoneLanguage {
            return hearthstoneLanguages.count
        }

        return 0
    }

    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        var language: String?
        if aComboBox == hstrackerLanguage {
            language = hstrackerLanguages[index]
        } else if aComboBox == hearthstoneLanguage {
            language = hearthstoneLanguages[index]
        }

        if let language = language {
            let locale = NSLocale(localeIdentifier: language)
            return locale.displayNameForKey(NSLocaleIdentifier, value: language)!.capitalizedString
        } else {
            return ""
        }
    }
}