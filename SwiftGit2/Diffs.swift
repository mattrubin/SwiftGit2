//
//  Diffs.swift
//  SwiftGit2
//
//  Created by Jake Van Alstyne on 8/20/17.
//  Copyright © 2017 GitHub, Inc. All rights reserved.
//
import Foundation
import libgit2

public struct StatusEntry {
	public var status: Diff.Status
	public var headToIndex: Diff.Delta?
	public var indexToWorkDir: Diff.Delta?

	public init(from statusEntry: git_status_entry) {
		self.status = Diff.Status(statusEntry.status)

		if let htoi = statusEntry.head_to_index {
			self.headToIndex = Diff.Delta(htoi.pointee)
		}

		if let itow = statusEntry.index_to_workdir {
			self.indexToWorkDir = Diff.Delta(itow.pointee)
		}
	}
}

public struct Diff {

	/// The set of deltas.
	public var deltas = [Delta]()

	public struct Delta {
		public static let type = GIT_OBJ_REF_DELTA

		public var status: Status
		public var flags: Flags
		public var oldFile: File?
		public var newFile: File?

		public init(_ delta: git_diff_delta) {
			self.status = Status(rawValue: UInt32(git_diff_status_char(delta.status)))
			self.flags = Flags(rawValue: delta.flags)
			self.oldFile = File(delta.old_file)
			self.newFile = File(delta.new_file)
		}
	}

	public struct File {
		public var oid: OID
		public var path: String
		public var size: Int64
		public var flags: Flags

		public init(_ diffFile: git_diff_file) {
			self.oid = OID(diffFile.id)
			let path = diffFile.path
			self.path = path.map(String.init(cString:))!
			self.size = diffFile.size
			self.flags = Flags(rawValue: diffFile.flags)
		}
	}

	public struct Status: OptionSet {
		public let rawValue: UInt32

		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}

		public init(_ status: git_status_t) {
			self.rawValue = status.rawValue
		}

		public static let current                = Status(GIT_STATUS_CURRENT)

		public static let indexNew               = Status(GIT_STATUS_INDEX_NEW)
		public static let indexModified          = Status(GIT_STATUS_INDEX_MODIFIED)
		public static let indexDeleted           = Status(GIT_STATUS_INDEX_DELETED)
		public static let indexRenamed           = Status(GIT_STATUS_INDEX_RENAMED)
		public static let indexTypeChange        = Status(GIT_STATUS_INDEX_TYPECHANGE)

		public static let workTreeNew            = Status(GIT_STATUS_WT_NEW)
		public static let workTreeModified       = Status(GIT_STATUS_WT_MODIFIED)
		public static let workTreeDeleted        = Status(GIT_STATUS_WT_DELETED)
		public static let workTreeTypeChange     = Status(GIT_STATUS_WT_TYPECHANGE)
		public static let workTreeRenamed        = Status(GIT_STATUS_WT_RENAMED)
		public static let workTreeUnreadable     = Status(GIT_STATUS_WT_UNREADABLE)

		public static let ignored                = Status(GIT_STATUS_IGNORED)
		public static let conflicted             = Status(GIT_STATUS_CONFLICTED)
	}

	public struct Flags: OptionSet {
		public let rawValue: UInt32

		public init(rawValue: UInt32) {
			self.rawValue = rawValue
		}

		public init(_ flags: git_diff_flag_t) {
			self.rawValue = flags.rawValue
		}

		public static let binary     = Flags(GIT_DIFF_FLAG_BINARY)
		public static let notBinary  = Flags(GIT_DIFF_FLAG_NOT_BINARY)
		public static let validId    = Flags(GIT_DIFF_FLAG_VALID_ID)
		public static let exists     = Flags(GIT_DIFF_FLAG_EXISTS)
	}

	/// Create an instance with a libgit2 `git_diff`.
	public init(_ pointer: OpaquePointer) {
		for i in 0..<git_diff_num_deltas(pointer) {
			if let delta = git_diff_get_delta(pointer, i) {
				deltas.append(Diff.Delta(delta.pointee))
			}
		}
	}
}
