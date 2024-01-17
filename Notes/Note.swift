//
//  Note.swift
//  Notes
//
//  Created by Spencer Jones on 1/16/24.
//

import Foundation
import SQLite3

struct Note {
    let id: Int
    var contents: String
}

class NoteManager {
    
    static let shared = NoteManager()
    
    private init() {}
    
    var database: OpaquePointer!
    
    func connect() {
        if database != nil { return }
        do {
            let databaseUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("notes.sqlite3")
            
            if sqlite3_open(databaseUrl.path, &database) == SQLITE_OK {
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS notes (contents TEXT)", nil, nil, nil) == SQLITE_OK {
                    
                } else {
                    print("could not create table")
                }
            } else {
                print("could not connect")
            }
            
        } catch let error{
            print("Could not create database")
        }
    }
    
    func create() -> Int {
        
        connect()
        
        var statement: OpaquePointer!
        
        if sqlite3_prepare_v2(database, "INSERT INTO notes (contents) VALUES ('New note')", -1, &statement, nil) != SQLITE_OK {
            print("could not create query")
            return -1
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("could not insert note")
        }
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    func getAllNotes() -> [Note] {
        connect()
        
        var result: [Note] = []
        var statement: OpaquePointer!
        
        if sqlite3_prepare_v2(database, "SELECT rowid, contents FROM notes", -1, &statement, nil) != SQLITE_OK {
            print("Error creating select")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Note(id: Int(sqlite3_column_int(statement, 0)), contents: String(cString: sqlite3_column_text(statement, 1))))
        }
        sqlite3_finalize(statement)
        return result
    }
    
    func save(note: Note) {
        
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare(database, "UPDATE notes SET contents = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating update statement")
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: note.contents).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(note.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error running update")
        }
        
        sqlite3_finalize(statement)
    }
        
}
