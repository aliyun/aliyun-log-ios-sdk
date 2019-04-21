//
//  DBManager.swift
//  AliyunLOGiOS
//
//  Created by huaixu on 2018/6/5.
//  Copyright © 2018年 wangjwchn. All rights reserved.
//

import Foundation
import FMDB

let sls_sql_create_table = "create table if not exists slslog (id integer primary key autoincrement, endpoint text, project text, logstore text, log text, timestamp double);vacuum slslog;"
let sls_sql_query_table_rowCount = "select count(*) as count from slslog;"
let sls_sql_query_table = "select * from slslog order by timestamp asc limit %lld"
let sls_sql_insert_records = "insert into slslog (endpoint, project, logstore, log, timestamp) VALUES (?, ?, ?, ?, ?)"
let sls_sql_delete_records = "delete from slslog where id in(select id from slslog order by timestamp asc limit %lld);vacuum slslog;"
let sls_sql_delete_specific_records = "delete from slslog where id=%@;"
let SLS_MAX_DB_SAVE_RECORDS = 10000



/// 数据库管理器.支持增,删,查操作
open class DBManager: NSObject {
    private static let `default`: DBManager = DBManager()
    public let dbPath = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appendingFormat("/slslog/log.sqlite")
    }
    private var dbQueue: FMDatabaseQueue?
    
    private override init() {
        let fm = FileManager.default
        let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appendingFormat("/slslog")
        if !fm.fileExists(atPath: folderPath!) {
            do {
                try fm.createDirectory(atPath: folderPath!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("failed to create folder: \(error.localizedDescription)")
            }
        }
        
        dbQueue = FMDatabaseQueue.init(path: dbPath())
    }
    
    open class func defaultManager() -> DBManager {
        let manager = self.default
        manager.checkTableExists()
        return manager
    }
    
    private func checkTableExists() {
        dbQueue?.inDatabase({ (db) in
            guard db.open() else {
                print("Unable to open database")
                return
            }
            
            do{
                try db.executeUpdate(sls_sql_create_table, values: nil)
            } catch {
                print("failed to create table: \(error.localizedDescription)")
            }
        })
    }
    
    
    /// asynchronously insert a record into db
    ///
    /// - Parameters:
    ///   - endpoint: endpoint's name
    ///   - project: project's name
    ///   - logstore: logstore's name
    ///   - log: log's message
    ///   - timestamp: timestamp when to invoke this method
    open func insertRecords(endpoint: String, project: String, logstore: String, log: String, timestamp: Double) {
        DispatchQueue.global().async {
            self.dbQueue?.inDatabase({ (db) in
                do {
                    try db.executeUpdate(sls_sql_insert_records, values: [endpoint, project, logstore, log, timestamp])
                } catch {
                    print("failed to insert record: \(error.localizedDescription)")
                }
            })
        }
    }
    
    
    /// asynchronously delete record from db
    ///
    /// - Parameter record: record,example:["id": "1"]
    open func deleteRecord(record: NSDictionary?) {
        guard record != nil else {
            return
        }
        
        DispatchQueue.global().async {
            self.dbQueue?.inDatabase({ (db) in
                do{
                    let id = (record! as NSDictionary).value(forKey: "id")
                    
                    let sql = String(format: sls_sql_delete_specific_records, arguments: [id as! CVarArg])
                    try db.executeUpdate(sql, values: nil)
                } catch {
                    print("failed to delete record: \(error.localizedDescription)")
                }
            })
        }
    }
    
    /// synchronously fetch records in db
    ///
    /// - Parameter range: limit
    /// - Returns: a array in which elements are dictionary
    open func fetchRecords(limit: Int) -> NSArray {
        let records: NSMutableArray = NSMutableArray.init()
        
        self.dbQueue?.inDatabase({ (db) in
            do{
                let query_sql = String.init(format: sls_sql_query_table, limit)
                
                let rs =  try db.executeQuery(query_sql, values: nil)
                while rs.next() {
                    let id = rs.unsignedLongLongInt(forColumn: SLS_TABLE_COLUMN_NAME.id.rawValue)
                    let endpoint = rs.string(forColumn: SLS_TABLE_COLUMN_NAME.endpoint.rawValue)
                    let project = rs.string(forColumn: SLS_TABLE_COLUMN_NAME.project.rawValue)
                    let logstore = rs.string(forColumn: SLS_TABLE_COLUMN_NAME.logstore.rawValue)
                    let log = rs.string(forColumn: SLS_TABLE_COLUMN_NAME.log.rawValue)
                    let timestamp = rs.double(forColumn: SLS_TABLE_COLUMN_NAME.timestamp.rawValue)
                    
                    if (endpoint != nil && project != nil && logstore != nil && log != nil) {
                        records.add([SLS_TABLE_COLUMN_NAME.id.rawValue: id,
                                        SLS_TABLE_COLUMN_NAME.endpoint.rawValue: endpoint!,
                                        SLS_TABLE_COLUMN_NAME.project.rawValue: project!,
                                        SLS_TABLE_COLUMN_NAME.logstore.rawValue: logstore!,
                                        SLS_TABLE_COLUMN_NAME.log.rawValue: log!,
                                        SLS_TABLE_COLUMN_NAME.timestamp.rawValue: timestamp])
                    }
                }
            } catch {
                print("failed to fetch records: \(error.localizedDescription)")
            }
        })
        
        return records.copy() as! NSArray
    }
    
    
    /// asynchronously delete records
    ///
    /// - Parameter count: count
    open func asyncDeleteRecords(count: Int) {
        DispatchQueue.global().async {
            self.dbQueue?.inDatabase({ (db) in
                
                let sql = String.init(format: sls_sql_delete_records, count)
                if (!db.executeStatements(sql)) {
                    print("failed to delete records. error: \(db.lastErrorMessage())")
                }
            })
        }
    }
    
    open func checkDBSize() {
        DispatchQueue.global().async {
            let fm = FileManager.default
            do {
                if let path = self.dbPath() {
                    let attributes = try fm.attributesOfItem(atPath: path)
                    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                        // 文件大于30M时，从数据库中删除按照时间正序前2k条记录
                        if fileSize > 1024 * 1024 * 30 {
                            self.asyncDeleteRecords(count: 2000)
                        }
                    }
                }
            } catch {
                print("failed to checkDBSize,error:\(error.localizedDescription)")
            }
        }
    }
}
