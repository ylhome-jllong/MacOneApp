//
//  GetIPAddresses.swift
//  IP
//
//  Created by 江龙 on 2020/5/29.
//  Copyright © 2020 江龙. All rights reserved.
//
import Cocoa
/// 用来获取IP地址的方法类
class GetIPAddresses: NSObject {
    /// 设备运营商IP（联通/移动/电信的运营商给的移动IP）
    static func getDeviceIP()->String?{
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
    
    /// WiFi获得的IP
    static func getWifiIP()->String?{
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }
         
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr,socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
         
        freeifaddrs(ifaddr)
        return address
    }
    
    /// 获得公网IP
    static func getPublicIP()->String?{
        var ip: String?
        if let url = URL(string: "https://pv.sohu.com/cityjson?ie=utf-8") ,
            let s = try? String(contentsOf: url, encoding: String.Encoding.utf8) {
            let subArr = s.components(separatedBy: ":")
            if subArr.count > 1  {
                let ipStr = subArr[1].replacingOccurrences(of: "\"", with: "")
                let ipSubArr = ipStr.components(separatedBy: ",")
                if ipSubArr.count > 0 {
                    ip = ipSubArr[0].trimmingCharacters(in: CharacterSet.whitespaces)
                }
            }
        }
        else {
            print("获得公网IP URL 转换失败")
        }
        return ip
    }

    /// 获取当前设备IP
    static func getOperatorsIP() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }

}
