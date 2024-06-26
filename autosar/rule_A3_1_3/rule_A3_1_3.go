/*
NaiveSystems Analyze - A tool for static code analysis
Copyright (C) 2023  Naive Systems Ltd.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

package rule_A3_1_3

import (
	"strings"

	"github.com/golang/glog"
	pb "naive.systems/analyzer/analyzer/proto"
	"naive.systems/analyzer/cruleslib/options"
	"naive.systems/analyzer/misra/checker_integration/csa"
)

func checkFileNameExtension(buildActions *[]csa.BuildAction) (*pb.ResultsList, error) {
	results := &pb.ResultsList{}
	for _, action := range *buildActions {
		path := action.Command.File
		if !strings.HasSuffix(path, ".cpp") {
			results.Results = append(results.Results, &pb.Result{
				Path:         path,
				LineNumber:   1,
				ErrorMessage: "Implementation files, that are defined locally in the project, should have a file name extension of \".cpp\".",
			})
		}
	}
	return results, nil
}

func Analyze(srcdir string, opts *options.CheckOptions) (*pb.ResultsList, error) {
	results, err := checkFileNameExtension(opts.EnvOption.BuildActions)
	if err != nil {
		glog.Error(err)
		return nil, err
	}
	return results, nil
}
