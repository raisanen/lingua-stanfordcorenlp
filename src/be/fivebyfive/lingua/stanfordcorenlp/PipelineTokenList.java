/*
 * Lingua::StanfordCoreNLP
 * Copyright © 2011-2013 Kalle Räisänen.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see L<http://www.gnu.org/licenses/>.
 */
package be.fivebyfive.lingua.stanfordcorenlp;

public class PipelineTokenList extends PipelineList<PipelineToken>  {
	@Override public String toCompactString() {
		return joinListCompact(" ");
	}

	@Override public String toString() {
		return joinList(" ");
	}
      
   public PipelineTokenList slice(int start, int end) {
      PipelineTokenList out = new PipelineTokenList();
      
      if (start < 0 || start > this.size() || end < 0 || end > this.size()) 
         return out;
      
      if (end < start) {
         int tmp = end;
         end = start;
         start = tmp;
      }
      
      for (int i = start; i < end; i++) {
         out.add(this.get(i));
      }
      
      return out;
   }
}