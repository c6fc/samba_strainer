<?php

if ($argv[1] != "ban" && $argv[1] != "unban") {

}

class SambaBanner {
   private $banlist;
   private $banlist_file;
   private $samba_template_file;

   public function __construct($banlist_file = "/etc/fail2ban/samba-vfs.banlist", $samba_template_file = "/etc/samba/smb.conf.tpl") {
      $this->banlist_file = $banlist_file;
      $this->samba_template_file = $samba_template_file;

      if (!file_exists($this->banlist_file)) {
         $this->banlist = array();
      } else {
         $this->banlist = json_decode(file_get_contents($this->banlist_file), true);
      }
   }

   public function ban($user, $ip) {
      if (!isset($this->banlist[$ip])) {
         $this->banlist[$ip] = array($user);
      } else {
         $this->banlist[$ip][] = $user;
      }

      return $this->save();
   }

   public function unban($ip) {
      if (!isset($this->banlist[$ip])) {
         return true;
      }

      unset($this->banlist[$ip]);
      return $this->save();
   }

   private function save() {
      file_put_contents($this->banlist_file, json_encode($this->banlist));
      return $this->generateFile();
   }

   public function generateFile() {
      $invalid_users = array();
      foreach ($this->banlist as $ip => $users) {
         foreach ($users as $x => $user) {
            $invalid_users[] = $user;
         }
      }

      $smb = file_get_contents($this->samba_template_file);
      $smb = str_replace('{{ invalid_users }}', implode(', ', $invalid_users), $smb);
      file_put_contents('/etc/samba/smb.conf', $smb);
   }
}

$sb = new SambaBanner();

switch ($argv[1]) {
   case "unban":
      $sb->unban($argv[2]);
   break;

   case "ban":
      $sb->ban($argv[2], $argv[3]);
   break;

   case "genfile":
      $sb->generateFile();
   break;

   default:
      die ("Syntax:\n " . $argv[0] . " <ban> <username> <ip>\n" . $argv[0] . " <unban> <ip>\n" . $argv[0] . " <genfile>\n");
   break;
}

?>

