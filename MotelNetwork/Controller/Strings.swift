//
//  Strings.swift
//  MotelNetwork
//
//  Created by Nguyên Duy on 4/10/18.
//  Copyright © 2018 Nguyên Duy. All rights reserved.
//

import Foundation
import UIKit

let myBlue: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
let myGray: UIColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
let paleGray = UIColor(red: 223/255, green: 232/255, blue: 236/255, alpha: 1.0)

let imageEmptyPost = UIImage(named: "")
let imageEmptySearch = UIImage(named: "")
let imageEmptyRoom = UIImage(named: "")

let API_KEY =  "AIzaSyCw_k4bba0yo3rvda0-e0qs7aPxK3XCd9s"
let districtList: [String] = ["Quận 1", "Quận 2", "Quận 3", "Quận 4", "Quận 5", "Quận 6", "Quận 7", "Quận 8", "Quận 9", "Quận 10", "Quận 11", "Quận 12", "Quận Thủ Đức", "Quận Bình Thạnh", "Quận Gò Vấp", "Quận Phú Nhuận", "Quận Tân Phú", "Quận Tân Bình", "Quận Bình Tân", "Huyện Nhà Bè", "Huyện Bình Chánh", "Huyện Hóc Môn", "Huyện Củ Chi" , "Huyện Cần Giờ"]
let messageConfirmLogOut: String = "Bạn chắc chắn muốn đăng xuất không?"
let messageRequestLogOut: String = "Bạn cần phải đăng nhập lại trước khi thay đổi email hoặc mật khẩu."
let messageEmailAlreadyUsed: String = "Email này đã được sử dụng. Vui lòng nhập email khác."
let messageCreateRoomSuccess: String = "Tạo phòng thành công"
let messageEditInfoSuccess: String = "Sửa thông tin thành công"
let messageNilTextFields: String = "Vui lòng nhập đầy đủ thông tin."
let messageSignUpSuccess: String = "Đăng ký thành công"
let messageLoginFailed: String = "Đăng nhập thất bại. Vui lòng kiểm tra lại email hoặc mật khẩu"
let messageChangeEmailSuccess: String = "Thay đổi email thành công"
let messageChangePasswordSuccess: String = "Thay đổi mật khẩu thành công"
let messageInvalidEmail: String = "Vui lòng nhập đúng định dạng email"
let messageNewPostSuccess: String = "Đăng tin thành công"
let messageEditPostSuccess: String = "Sửa tin thành công"
let messageLimitCharacters: String = "Vui lòng không nhập quá số kí tự cho phép"
let messagePasswordLessThan6Chars: String = "Mật khẩu phải từ 6 kí tự trở lên"
let messageConfirmChangePassword: String = "Bạn có chắc chắn muốn đổi mật khẩu không?"
let messageConfirmChangeEmail: String = "Bạn có chắc chắn muốn đổi email không?"
let messageConfirmDeleteRoom: String = "Bạn có muốn xóa phòng này không?"
let messageConfirmDeletePost: String = "Bạn có muốn xóa tin này không?"
let messageConfirmDeleteBill: String = "Bạn có muốn xóa hóa đơn này không?"
let messageConfirmEditData: String = "Bạn có muốn sửa thông tin không?"
let messageCreateNotiSuccess: String = "Lưu thông báo thành công"
let messageCreateBillSuccess: String = "Lưu hóa đơn thành công"
let messageEditBillSuccess: String = "Sửa hóa đơn thành công"
let messageNilImages: String = "Bạn chưa chọn ảnh"
let messageWrongPasswordConfirm: String = "Mật khẩu xác nhận không giống mật khẩu mới. Vui lòng kiểm tra lại"
let messageInvalidPhoneNumber: String = "Vui lòng nhập đúng số điện thoại"
let messageGPSAccessDenied: String = "Motel Network không có quyền truy cập vào vị trí hiện tại của bạn. Bạn có thể thay đổi trong Cài đặt"
let messageEmptyRoom: String = "Bạn chưa có phòng nào.\nNhấn nút '+' để bắt đầu tạo phòng mới."
let messageEmptyBill: String = "Bạn chưa có hóa đơn nào.\nTính tiền phòng để tạo hóa đơn mới."
let messageEmptyRoomForRenter: String = "Bạn chưa thuê phòng nào.\nLiên hệ chủ phòng trọ để được thêm vào phòng (nếu có)."
let messageEmptyPost: String = "Bạn chưa có bài đăng nào.\nNhấn nút 'Đăng tin' để bắt đầu đăng bài mới."
let messageEmptySearch: String = "Không tìm thấy bài đăng theo yêu cầu của bạn."
let messageEmptyPostForHome: String = "Không có bài đăng nào."
let messageEmptyPostNearMe: String = "Không có bài đăng gần bạn."
let messageSavePostSuccess: String = "Lưu tin thành công."
let messageConfirmDeleteSavedPost: String = "Bạn có muốn bỏ lưu tin này không?"
let messageDeleteSavedPostSuccess: String = "Bỏ lưu thành công."
let messageSendFeedbackSuccess: String = "Gửi phản hồi thành công."


