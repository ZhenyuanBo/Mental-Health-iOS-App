/*
 Author: Zhenyuan Bo
 File Description: Catch All Error Messages in the Log File
 Date: Dec 18, 2020
 */
import Foundation

class Log: TextOutputStream {

    func write(_ string: String) {
        let fm = FileManager.default
        let date = Date().dateFormatter(format: "MM-dd-yyyy")
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(date)_MHA_SysLog.log")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
    static var log: Log = Log()
    private init() {} // we are sure, nobody else could create it
}
