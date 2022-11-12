// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Mine {

    struct Student {
        uint id;
        string name;
    }
    struct Subject {
        uint id;
        string name;
    }

    mapping (uint => Student) private studentById;
    mapping (uint => Subject) private subjectById;

    mapping (address => uint[]) private profToSubjects;
    mapping (uint => uint[]) private subjectToStudents;

    mapping (uint => mapping (uint => uint)) private scores;

    function validate (uint x, uint id) view private {
        if (x == 0) {
            require(bytes(studentById[id].name).length != 0, "Student doesn't exist");
        } else if (x == 1) {
            require(bytes(subjectById[id].name).length != 0, "Subject doesn't exist");
        }
    }

    function insertStudent (uint id, string memory name) public {
        studentById[id] = Student(id, name);
    }

    function insertStudentToSubject (uint subjectId, uint studentId) public {
        validate(0, studentId);
        validate(1, subjectId);
        
        subjectToStudents[subjectId].push(studentId);
    }

    function insertSubject (uint id, string memory name) public {
        require(subjectById[id].id != id, "ID subject already exists");

        subjectById[id] = Subject(id, name);
        profToSubjects[msg.sender].push(id);
    }

    function insertScores (uint studentId, uint subjectId, uint score) public {
        validate(0, studentId);
        validate(1, subjectId);

        uint subjectsTotal = profToSubjects[msg.sender].length;
        bool subjectReg = false;
        for (uint i = 0; i < subjectsTotal; i++) {
            uint subId = profToSubjects[msg.sender][i];
            if (subId == subjectId) {
                subjectReg = true;
            }
        }
        if (subjectReg == false) {
            revert("You're not the professor of this subject");
        }

        uint totalStudents = subjectToStudents[subjectId].length;
        bool studentReg = false;
        for (uint i = 0; i < totalStudents; i++) {
            if (subjectToStudents[subjectId][i] == studentId) {
                studentReg = true;
            }
        }
        if (studentReg == false) {
            revert("Student is not in this subject");
        }

        scores[studentId][subjectId] = score;
    }

    function getSubjectsList () view public returns (Subject[] memory) {
        uint subjectsTotal = profToSubjects[msg.sender].length;

        Subject[] memory subjects = new Subject[](subjectsTotal);

        for(uint i = 0; i < subjectsTotal; i++){
            uint subjectId = profToSubjects[msg.sender][i];
            subjects[i] = subjectById[subjectId];
        }
        return subjects;
    }

}